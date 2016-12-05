# encoding: utf-8
class Crawler::Wenku8
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".css tr td")
    url = @page_url.gsub("index.htm","")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      if node[:class] == "vcss"
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      else
        a_node = node.css("a")[0]
        next if a_node.nil?
        do_not_crawl_from_link = false if crawl_this_article(from_link,a_node[:href])
        next if do_not_crawl_from_link

        if novel_id == 6834
          do_not_crawl = false if a_node[:href] == "http://www.wenku8.com/modules/article/reader.php?aid=884&cid=67251"
          next if do_not_crawl
        end

        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + a_node[:href])
 
        next if article
        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + a_node[:href]
        article.title = ZhConv.convert("zh-tw",a_node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = subject
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
        end
        ArticleWorker.perform_async(article.id)    
      end
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")
    node.css("#contentdp").remove
    text = node.text
    text = ZhConv.convert("zh-tw", text.strip,false)
    if text.length < 100
      imgs = @page_html.css("#content .divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novel category_id
    link = @page_html.css("span[style='width:125px;display:inline-block;']")[0].css("a")[0][:href]
    author = @page_html.css("td[width='25%']")[1].text.gsub("小说作者：","")
    name = @page_html.css("td[width='80%'][align='center'][valign='middle'] b").text

    html = @page_html.css("td[width='80%'][valign='top']")
    html.css(".hottext, a").remove
    description = html.text.strip
    
    pic = @page_html.css("td[width='20%'][align='center'][valign='top'] img")[0][:src]
    is_serializing = (@page_html.css("td[width='25%']")[2].text.index("连载中") ? true : false)
    
    novel =  Novel.find_by_link link
    unless novel
      novel = Novel.new
      novel.link = link
      novel.name = ZhConv.convert("zh-tw",name,false)
      novel.author = ZhConv.convert("zh-tw",author,false)
      novel.description = ZhConv.convert("zh-tw",description,false)
      novel.category_id = category_id
      novel.is_show = true
      novel.is_serializing = is_serializing
      novel.pic = pic
      novel.article_num = "?"
      novel.last_update = Time.now.strftime("%y-%m-%d")
      novel.save
      CrawlWorker.perform_async(novel.id)
    end
    novel
  end

  def crawl_rank
    nodes = @page_html.css(".ultop")

    nodes.each_with_index do |node,i|
      a_nodes = node.css("a")
      a_nodes.each do |a_node|

        novel_intro_link = a_node[:href]
        novel_name = ZhConv.convert("zh-tw",a_node.text.strip,false)
        /id=(\d*)/ =~ a_node[:href]
        novel_link = "http://www.wenku8.cn/novel/#{$1.to_i / 1000}/#{$1}/index.htm"

        novel =  Novel.find_by_link(novel_link)
        novel =  Novel.find_by_name(novel_name) unless novel
        
        begin
          unless novel
            crawler = CrawlerAdapter.get_instance novel_intro_link
            crawler.fetch novel_intro_link
            novel = crawler.crawl_novel 23
          end
          case i
          when 0..5
            novel.is_category_recommend = true
          when 6..10
            novel.is_category_this_week_hot = true
          else
            novel.is_category_hot = true
          end
          novel.save
        rescue
        end
      end
    end
  end

end