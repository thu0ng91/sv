# encoding: utf-8
class YqArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "yq_novel_article", :retry => 2
  
  def perform(article_id)
    article = Article.select("title, id, link, is_show").find(article_id)
    crawler = CrawlerAdapter.get_instance article.link
    crawler.fetch article.link
    crawler.crawl_article article
  end
end