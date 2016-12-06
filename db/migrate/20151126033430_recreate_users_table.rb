class RecreateUsersTable < ActiveRecord::Migration
  def change
    drop_table :users
    create_table :users do |t|
      t.string :email
      t.text :collect_novels
      t.text :download_novels

      t.timestamps
    end
    add_index  :users, :email
  end
end
