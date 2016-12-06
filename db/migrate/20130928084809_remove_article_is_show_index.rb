class RemoveArticleIsShowIndex < ActiveRecord::Migration
  def up
    remove_index  :articles, :is_show
  end

  def down
  end
end
