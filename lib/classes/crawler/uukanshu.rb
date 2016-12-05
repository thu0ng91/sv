# encoding: utf-8
class Crawler::Uukanshu
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#chapterList a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.reverse_each do |node|
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 23033
        do_not_crawl = false if node[:href] == '/b/25080/142369.html'
        next if do_not_crawl
      end
      if novel_id == 23463
        do_not_crawl = false if node[:href] == '/b/30530/119958.html'
        next if do_not_crawl
      end
      if novel_id == 22801
        do_not_crawl = false if node[:href] == '/b/30981/119690.html'
        next if do_not_crawl
      end
      if novel_id == 23515
        do_not_crawl = false if node[:href] == '/b/11360/129550.html'
        next if do_not_crawl
      end
      if novel_id == 23271
        do_not_crawl = false if node[:href] == '/b/29508/125824.html'
        next if do_not_crawl
      end
      if novel_id == 22521
        do_not_crawl = false if node[:href] == '/b/29932/125794.html'
        next if do_not_crawl
      end
      if novel_id == 23221
        do_not_crawl = false if node[:href] == '/b/29753/125062.html'
        next if do_not_crawl
      end
      if novel_id == 22061
        do_not_crawl = false if node[:href] == '/b/27371/154754.html'
        next if do_not_crawl
      end
      if novel_id == 23391
        do_not_crawl = false if node[:href] == '/b/31700/116484.html'
        next if do_not_crawl
      end
      if novel_id == 23141
        do_not_crawl = false if node[:href] == '/b/29098/139854.html'
        next if do_not_crawl
      end
      if novel_id == 22373
        do_not_crawl = false if node[:href] == '/b/26608/157272.html'
        next if do_not_crawl
      end
      if novel_id == 23319
        do_not_crawl = false if node[:href] == '/b/30660/120951.html'
        next if do_not_crawl
      end
      if novel_id == 22691
        do_not_crawl = false if node[:href] == '/b/29909/126149.html'
        next if do_not_crawl
      end
      if novel_id == 21685
        do_not_crawl = false if node[:href] == '/b/10053/94848.html'
        next if do_not_crawl
      end
      if novel_id == 17103
        do_not_crawl = false if node[:href] == '/b/8496/106147.html'
        next if do_not_crawl
      end
      if novel_id == 21335
        do_not_crawl = false if node[:href] == '/b/26537/157063.html'
        next if do_not_crawl
      end
      if novel_id == 23283
        do_not_crawl = false if node[:href] == '/b/29128/139448.html'
        next if do_not_crawl
      end
      if novel_id == 17501
        do_not_crawl = false if node[:href] == '/b/302/365105.html'
        next if do_not_crawl
      end
      if novel_id == 18148
        do_not_crawl = false if node[:href] == '/b/1792/198986.html'
        next if do_not_crawl
      end
      if novel_id == 21442
        do_not_crawl = false if node[:href] == '/b/28241/125136.html'
        next if do_not_crawl
      end
      if novel_id == 22669
        do_not_crawl = false if node[:href] == '/b/29389/139906.html'
        next if do_not_crawl
      end
      if novel_id == 22635
        do_not_crawl = false if node[:href] == '/b/27960/135044.html'
        next if do_not_crawl
      end
      if novel_id == 21257
        do_not_crawl = false if node[:href] == '/b/26238/145869.html'
        next if do_not_crawl
      end
      if novel_id == 20941
        do_not_crawl = false if node[:href] == '/b/24124/154732.html'
        next if do_not_crawl
      end
      if novel_id == 20568
        do_not_crawl = false if node[:href] == '/b/10313/89305.html'
        next if do_not_crawl
      end
      if novel_id == 20740
        do_not_crawl = false if node[:href] == '/b/25249/142789.html'
        next if do_not_crawl
      end
      if novel_id == 23113
        do_not_crawl = false if node[:href] == '/b/18174/142962.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#contentbox")
    node.css("script,a").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novel(category_id)
    img_link = @page_html.css(".bookImg img")[0][:src]
    name = @page_html.css(".jieshao_content h1")[0].text.gsub("最新章节","")
    is_serializing = true
    is_serializing = false if @page_html.css(".status-text").text.include?("完结")
    author = @page_html.css(".jieshao_content h2 a")[0].text
    description = change_node_br_to_newline(@page_html.css(".jieshao_content h3")).gsub("www.uukanshu.com","").gsub("http://Www.uuKanShu.Com","").gsub("－","").strip
    link = @page_url
    
    novel = Novel.new
    novel.link = link
    novel.name = ZhConv.convert("zh-tw",name,false)
    novel.author = ZhConv.convert("zh-tw",author,false)
    novel.category_id = category_id
    novel.is_show = true
    novel.is_serializing = is_serializing
    novel.last_update = Time.now.strftime("%m/%d/%Y")
    novel.article_num = "?"
    novel.description = description
    novel.pic = img_link
    novel.save
    CrawlWorker.perform_async(novel.id)
    novel.id
  end

end