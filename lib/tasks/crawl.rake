# encoding: utf-8
namespace :crawl do
  task :crawl_novel_link => :environment do
    categories = Category.all
    
    categories.each do |category|

      (1..100).each do |i|
        CrawlNewNovelWorker.perform_async(category.id,i)
      end
    end
  end

  # task :crawl_cat_ranks => :environment do
  #   Novel.update_all({:is_category_recommend => false , :is_category_hot => false, :is_category_this_week_hot => false})
  #   categories = Category.all
    
  #   categories.each do |category|
  #     crawler = CrawlerAdapter.get_instance category.cat_link
  #     crawler.fetch category.cat_link
  #     crawler.crawl_cat_rank category.id
  #   end
  # end

  # task :crawl_rank => :environment do
  #   ThisWeekHotShip.delete_all
  #   ThisMonthHotShip.delete_all
  #   HotShip.delete_all
  #   url = "http://www.bestory.com/html/r-1.html"
  #   crawler = CrawlerAdapter.get_instance url
  #   crawler.fetch url
  #   crawler.crawl_rank
  # end

  task :crawl_this_week_hot_rank => :environment do
    ThisWeekHotShip.delete_all
    Novel.update_all("is_category_this_week_hot = false", "category_id > 13 and category_id < 23")

    url = "http://www.ranwen.net/modules/article/toplist.php?sort=weekvisit&page="
    
    (1..30).each do |i|
      crawler = CrawlerAdapter.get_instance "#{url}#{i}"
      crawler.fetch "#{url}#{i}"
      crawler.crawl_hot_rank "ThisWeekHotShip" 
    end
  end

  task :crawl_this_month_hot_rank => :environment do
    ThisMonthHotShip.delete_all

    url = "http://www.ranwen.net/modules/article/toplist.php?sort=monthvisit&page="
    
    (1..30).each do |i|
      crawler = CrawlerAdapter.get_instance "#{url}#{i}"
      crawler.fetch "#{url}#{i}"
      crawler.crawl_hot_rank "ThisMonthHotShip"
    end
  end

  task :crawl_hot_rank => :environment do
    HotShip.delete_all
    Novel.update_all("is_category_hot = false", "category_id > 13 and category_id < 23")

    url = "http://www.ranwen.net/modules/article/toplist.php?sort=allvisit&page="
    
    (1..30).each do |i|
      crawler = CrawlerAdapter.get_instance "#{url}#{i}"
      crawler.fetch "#{url}#{i}"
      crawler.crawl_hot_rank "HotShip"
    end
  end

  task :crawl_category_recommend_rank => :environment do
    url = "http://www.ranwen.net/modules/article/toplist.php?sort=monthvote&page="
    Novel.update_all("is_category_recommend = false", "category_id > 13 and category_id < 23")

    (1..30).each do |i|
      crawler = CrawlerAdapter.get_instance "#{url}#{i}"
      crawler.fetch "#{url}#{i}"
      crawler.crawl_category_recommend_rank
    end
  end

  task :crawl_light_novel_rank => :environment do
    #category_23
    Novel.update_all({:is_category_recommend => false , :is_category_hot => false, :is_category_this_week_hot => false},"category_id = 23")
    url = "http://www.wenku8.cn/top.php"
    crawler = CrawlerAdapter.get_instance url
    crawler.fetch url
    crawler.crawl_rank
  end

  task :crawl_time_travel_novel => :environment do
    # need find time to implement it
  end

  # task :change_wenku8_link => :environment do
  #   Novel.where(["link like ?", "%wenku8%"]).each do |novel|
  #     unless novel.link.index("htm")
  #       /id=(\d*)/ =~ novel.link
  #       novel.link = "http://www.wenku8.cn/novel/#{$1.to_i / 1000}/#{$1}/index.htm"
  #       novel.save
  #     end
  #   end
  # end

  task :crawl_articles_and_update_novel => :environment do
    Novel.where("is_show = true and is_serializing = true").select("id").find_in_batches do |novels|
      novels.each do |novel|
        CrawlWorker.perform_async(novel.id)
      end
    end
  end

  task :set_novel_last_update_and_num => :environment do
    Novel.select("id,last_update,article_num").find_in_batches do |novels|
      novels.each do |novel|
        if novel.articles.show.size > 0
          time = novel.articles.show.last.created_at.strftime("%y-%m-%d")
          novel.last_update = time
          novel.article_num = novel.articles.show.size.to_s + "篇"
          novel.save
        end
      end
    end
  end

  task :send_notification => :environment do
    gcm = GCM.new("AIzaSyBSeIzNxqXm2Rr4UnThWTBDXiDchjINbrc")
    u = User.find(2)
    registration_ids= ["APA91bGxJM5H56NzVECqZs3rHUgQfubcEld5lehLAzz08Ok41EiRBmoz7X-8OL1x7Jte3Q1lc3nyFsVU5pCK3kx3i9jmurQjK4pTXbNkDnev_zHImTOIboUdftOSntW8qpuiyFZ7Mj2xk7DGDl31aqcSHoB2sDHaEQ"]
    options = {data: {
                  activity: 5, 
                  title: "小說王出新版本囉", 
                  big_text: "新功能，xxxx", 
                  content: "我是 content", 
                  is_resent: true, 
                  category_name: "test", 
                  category_id: 1,
                  novel_name: "novel_name",
                  novel_author: "novel_author",
                  novel_description: "novel_description",
                  novel_update: "20000",
                  novel_pic_url: "http",
                  novel_article_num: "2222",
                  novel_id: 133,
                  open_url: "https://play.google.com/store/apps/details?id=com.novel.reader"
                  }, collapse_key: "updated_score"}
    response = gcm.send_notification(registration_ids, options)
  end

end