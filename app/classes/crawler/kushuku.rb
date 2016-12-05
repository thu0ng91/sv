# encoding: utf-8
class Crawler::Kushuku
  include Crawler
  
  def crawl_article article
    @page_html.css("span").remove
    node = @page_html.css("#content")
    text = change_node_br_to_newline(node)
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end