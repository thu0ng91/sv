class CreateThisMonthHotShips < ActiveRecord::Migration
  def change
    create_table :this_month_hot_ships do |t|
      t.integer :novel_id
      t.timestamps
    end
    add_index :this_month_hot_ships, :novel_id
  end
end
