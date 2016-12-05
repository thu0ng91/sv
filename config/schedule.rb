env :PATH, ENV['PATH']

every :day, :at => '04:00am' do
  rake 'crawl:crawl_articles_and_update_novel',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end