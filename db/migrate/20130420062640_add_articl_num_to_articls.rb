class AddArticlNumToArticls < ActiveRecord::Migration
  def change
    add_column :articles, :num, :integer, :default => 0
    add_index  :articles, :num
  end
end
