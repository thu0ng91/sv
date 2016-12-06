class CreateThisWeekHotShips < ActiveRecord::Migration
  def change
    create_table :this_week_hot_ships do |t|
      t.integer :novel_id
      t.timestamps
    end
    add_index :this_week_hot_ships, :novel_id
  end
end
