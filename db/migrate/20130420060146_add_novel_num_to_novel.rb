class AddNovelNumToNovel < ActiveRecord::Migration
  def change
    add_column :novels, :num, :integer, :default => 0
    add_index  :novels, :name
    add_index  :novels, :author
    add_index  :novels, :num
  end
end
