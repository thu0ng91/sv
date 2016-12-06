class AddCrawlNovelTimesToNovel < ActiveRecord::Migration
  def change
    add_column :novels, :crawl_times, :integer, :default => 0
  end
end
