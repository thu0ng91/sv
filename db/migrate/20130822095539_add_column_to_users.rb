class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :device_id, :string
    add_index  :users, :device_id
    add_column :users, :downloaded_novels, :text
    add_column :users, :collected_novels, :text
  end
end
