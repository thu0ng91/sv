# encoding: utf-8
class Crawler::Antscreation
  include Crawler

  def crawl_article article
    text = @page_html.css(".desc").text.strip

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end