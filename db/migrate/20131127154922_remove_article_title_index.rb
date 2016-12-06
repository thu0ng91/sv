class RemoveArticleTitleIndex < ActiveRecord::Migration
  def up
    remove_index :articles, :title
  end

  def down
    add_index :articles, :title
  end
end
