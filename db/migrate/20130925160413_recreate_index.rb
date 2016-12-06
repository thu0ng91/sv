class RecreateIndex < ActiveRecord::Migration
  def up
    remove_index :novels, :category_id
    remove_index :this_month_hot_ships, :novel_id
    remove_index :this_week_hot_ships, :novel_id
    remove_index :hot_ships, :novel_id
    remove_index :articles, :novel_id
    remove_index :articles, :link
    remove_index :articles, :title
    remove_index  :novels, :name
    remove_index  :novels, :author
    remove_index  :novels, :num
    remove_index  :articles, :num
    remove_index  :novels, :is_show
    remove_index  :articles, :is_show
    remove_index  :users, :device_id

    
    add_index :novels, :category_id
    add_index :this_month_hot_ships, :novel_id
    add_index :this_week_hot_ships, :novel_id
    add_index :hot_ships, :novel_id
    add_index :articles, :novel_id
    add_index :articles, :link
    add_index :articles, :title
    add_index  :novels, :name
    add_index  :novels, :author
    add_index  :novels, :num
    add_index  :articles, :num
    add_index  :novels, :is_show
    add_index  :articles, :is_show
    add_index  :users, :device_id
  end

  def down
  end
end
