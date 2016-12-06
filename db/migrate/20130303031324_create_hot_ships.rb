class CreateHotShips < ActiveRecord::Migration
  def change
    create_table :hot_ships do |t|
      t.integer :novel_id
      t.timestamps
    end
    add_index :hot_ships, :novel_id
  end
end
