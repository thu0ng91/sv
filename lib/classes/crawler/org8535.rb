# encoding: utf-8
class Crawler::Org8535
  include Crawler
  
  def crawl_article article
    @page_html.css("#bookcontent #adtop, #bookcontent #endtips").remove
    text = @page_html.css("#bookcontent").text.strip
    article_text = ZhConv.convert("zh-tw",text,false)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end