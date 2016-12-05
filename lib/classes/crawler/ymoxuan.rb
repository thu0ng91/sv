# encoding: utf-8
class Crawler::Ymoxuan
  include Crawler

  def crawl_article article
    imgs = @page_html.css("#readtext .divimage img")
    text_img = ""
    imgs.each do |img|
        text_img = text_img + img[:src] + "*&&$$*"
    end
    text_img = text_img + "如果看不到圖片, 請更新至新版APP"
    text = text_img
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end