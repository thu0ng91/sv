class NovelCrawlFrom < ActiveRecord::Migration
  def change
    create_table :from_links do |t|
      t.integer :novel_id
      t.string :link
    
      t.timestamps
    end
    add_index :from_links, :novel_id
  end
end
