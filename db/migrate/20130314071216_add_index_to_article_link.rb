class AddIndexToArticleLink < ActiveRecord::Migration
  def change
    add_index :articles, :link
    add_index :articles, :title
  end
end
