# encoding: utf-8
class Crawler::Dollars2
  include Crawler

  def crawl_article article
    node = @page_html.css(".t_f")
    node.css("font.jammer,span[style=\"display:none\"]").remove
    text = node.text.strip
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end