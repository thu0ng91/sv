# encoding: utf-8
class NovelRecrawlExitedArticleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel_recrawl_exited_article", :retry => 2
  
  def perform(novel_id)
    novel = Novel.find(novel_id)
    novel.recrawl_articles_text
  end
end