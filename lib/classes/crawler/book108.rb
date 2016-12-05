# encoding: utf-8
class Crawler::Book108
  include Crawler
  
  def crawl_article article
    @page_html.css("#content a").remove
    text = @page_html.css("#content p").text
    text2 = text.gsub("1０８尒説WWW.Book１０８。com鯁","")
    article_text = ZhConv.convert("zh-tw",text2,false)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end