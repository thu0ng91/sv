# encoding: utf-8
class Crawler::Papaxs
  include Crawler

  def crawl_article article
    text = ""
    if text.length < 100
      begin
        imgs = @page_html.css(".divimage img")
        text_img = ""
        imgs.each do |img|
            text_img = text_img + img[:src] + "*&&$$*"
        end
        text_img = text_img + "如果看不到圖片, 請更新至新版APP"
        text = text_img
      rescue Exception => e      
      end
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)   
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end
