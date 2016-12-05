# encoding: utf-8
class CrawlWorker
  include Sidekiq::Worker
  sidekiq_options queue: "novel", :retry => 2
  
  def perform(novel_id)
    novel = Novel.select("id, link, is_show").find(novel_id)
    # return if novel.is_show == false

    crawler = CrawlerAdapter.get_instance novel.link
    crawler.fetch novel.link
    crawler.crawl_novel_detail novel.id if(novel.link.index('bestory'))
    crawler.crawl_articles novel.id
    puts novel.id
  end
end