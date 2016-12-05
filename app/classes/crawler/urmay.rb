# encoding: utf-8
class Crawler::Urmay
  include Crawler

  def crawl_article article
    node = @page_html.css(".t_msgfont")
    text = change_node_br_to_newline(node).strip
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end