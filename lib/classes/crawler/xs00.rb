# encoding: utf-8
class Crawler::Xs00
  include Crawler

  def crawl_article article

    @page_html.css("div#msg-bottom,script").remove
    text = change_node_br_to_newline(@page_html.css("#content")).strip
    text = ZhConv.convert("zh-tw", text,false)

    if text.length < 100
      imgs = @page_html.css(".imagecontent")
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

  def crawl_articles novel_id
    url = @page_url.sub("index.html","")
    nodes = @page_html.css(".booklist a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 20731
        do_not_crawl = false if node[:href] == '10287279.html'
        next if do_not_crawl
      end
      if novel_id == 21603
        do_not_crawl = false if node[:href] == '10358743.html'
        next if do_not_crawl
      end
      if novel_id == 18411
        do_not_crawl = false if node[:href] == '9811795.html'
        next if do_not_crawl
      end
      if novel_id == 22429
        do_not_crawl = false if node[:href] == '9906022.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        if novel_id == 20731
          article.num = novel.num + 1 + 7688162
        else
          article.num = novel.num + 1
        end
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

end