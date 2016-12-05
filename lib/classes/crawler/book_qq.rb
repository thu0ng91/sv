# encoding: utf-8
class Crawler::BookQq
  include Crawler
  
  def crawl_article article
    nodes = @page_html.css("#content")
    text  = change_node_br_to_newline(nodes)
    article_text = ZhConv.convert("zh-tw", text,false)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end