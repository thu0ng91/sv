# encoding: utf-8
class Crawler::Yunshuge
  include Crawler
  
  def crawl_article article
    node = @page_html.css("#content")
    text = change_node_br_to_newline(node).strip
    text = text.gsub("www.biquge.com ","")

    if text.length < 100
      imgs = @page_html.css("#imgview")
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