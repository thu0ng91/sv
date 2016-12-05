# encoding: utf-8
class Crawler::Baby91
  include Crawler

  def crawl_article article
    node = @page_html.css(".t_f")
    text = node.text.strip
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end