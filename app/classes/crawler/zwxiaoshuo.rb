# encoding: utf-8
class Crawler::Zwxiaoshuo
  include Crawler


  def crawl_novels category_id
    nodes = @page_html.css("#lbox ul")
    nodes.each do |node|
      link = "http://www.zwxiaoshuo.com/" + node.css(".t3 a")[0][:href]
      description = node.css(".t3 a")[0][:title]
      author = node.css(".t4 a")[0].text
      update_time = Time.now.strftime("%Y-%m-%d")
      is_serializing = (node.css(".t1.red12").text == "已完成")
      name = node.css(".t3 a")[0].text
      article_num = "全"
      c = Crawler::Zwxiaoshuo.new
      c.fetch link
      novel_link = "http://www.zwxiaoshuo.com" + c.page_html.css("#htmltimu")[0][:href]

      novel =  Novel.find_by_link novel_link
      unless novel
        novel = Novel.new
        novel.link = novel_link
        novel.name = ZhConv.convert("zh-tw",name,false)
        novel.author = ZhConv.convert("zh-tw",author,false)
        novel.description = ZhConv.convert("zh-tw",description,false)
        novel.category_id = category_id
        novel.is_show = true
        novel.is_serializing = is_serializing
        novel.last_update = update_time
        novel.article_num = article_num
        novel.pic = nil
        novel.save
      end
      CrawlWorker.perform_async(novel.id)
      sleep 10
    end
  end

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css(".insert_list li a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|   
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        /(\d*)/ =~ node[:href]
        article.num = $1.to_i + novel.num
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    @page_html.css(".contentbox div").remove
    text = @page_html.css(".contentbox").text.strip
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end