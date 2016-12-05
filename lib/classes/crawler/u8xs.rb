# encoding: utf-8
class Crawler::U8xs
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".booklist span")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      if(node[:class]=="v")
        subject = ZhConv.convert("zh-tw",node.text.strip.gsub(".",""),false)
      else
        a_node = node.css("a")[0]
        do_not_crawl_from_link = false if crawl_this_article(from_link,a_node[:href])
        next if do_not_crawl_from_link

        url = @page_url.gsub("index.html","") + a_node[:href]
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
        next if article
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",a_node.text.strip,false) 
          article.subject = subject
          /(\d*)\.html/ =~ a_node[:href]
          next unless $1
          article.num = $1.to_i
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    end
    set_novel_last_update_and_num(novel_id)
  end
  
  def crawl_article article
    text = change_node_br_to_newline(@page_html.css("#content"))
    article_text = ZhConv.convert("zh-tw",text,false)
    text = article_text
    
    if text.length < 100
      imgs = @page_html.css(".divimage img")
      imgs = @page_html.css("#content_text img") unless imgs.present?
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