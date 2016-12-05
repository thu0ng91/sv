# encoding: utf-8
class Crawler::NovelCrawler
  include Crawler

  def crawl_article article
    if (@page_url.index('qiuwu'))
      text = @page_html.css("#content").text.strip
      text = ZhConv.convert("zh-tw", text,false)
      raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
      ArticleText.update_or_create(article_id: article.id, text: text)
    end
  end
end
