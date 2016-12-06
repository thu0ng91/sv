class AddIsShowToNovelAndArticle < ActiveRecord::Migration
  def change
    add_column :articles, :is_show, :boolean, :default => true
    add_column :novels, :is_show, :boolean, :default => true
    add_index  :novels, :is_show
    add_index  :articles, :is_show
  end
end
