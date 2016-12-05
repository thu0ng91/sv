# encoding: utf-8
class Crawler::Klxsw
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("td[width='25%'] a")
    next_article = true

    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      url = @page_url.gsub("index.html","")
      article_url = ""
      if node[:href].index("klxsw.com")
        article_url = node[:href]
      else
        article_url = url+ node[:href]
      end
      
      if novel_id == 20722
        next_article = false if node[:href] == "http://www.klxsw.com/modules/article/reader.php?aid=89598&cid=16649835 "
        next_article = true if node[:href] == "http://www.klxsw.com/modules/article/reader.php?aid=89598&cid=16650429"
        next if next_article
      end

      if novel_id == 22341
        next_article = false if node[:href] == "http://www.klxsw.com/modules/article/reader.php?aid=171726&cid=29222895"
        next if next_article
      end
      if novel_id == 22753
        next_article = false if node[:href] == "http://www.klxsw.com/modules/article/reader.php?aid=192486&cid=29428807"
        next if next_article
      end

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(article_url)
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = article_url
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
    text = change_node_br_to_newline(@page_html.css("#r1c")).strip
    text = ZhConv.convert("zh-tw", text,false)

     if text.size < 100
      imgs = @page_html.css(".divimage img")
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

end