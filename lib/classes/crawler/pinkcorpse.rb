# encoding: utf-8
class Crawler::Pinkcorpse
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".pages a.last")
    last_node = nodes.last
    url = @page_url.gsub(/page=(\d*)/,"page=")
    /page=(\d*)/ =~ last_node[:href]
    (1..$1.to_i).each do |i|
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + i.to_s)
      ArticleWorker.perform_async(article.id) if(i==$1 && article) 
      next if article
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + i.to_s
        article.title = i.to_s
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
    node = @page_html.css(".t_msgfont")
    node.css("span").remove
    node.css("font[style='font-size:0px;color:#FAFAFA']").remove
    text = change_node_br_to_newline(node)
    if text.size < 100
      imgs = page.all('.t_attachlist img')
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