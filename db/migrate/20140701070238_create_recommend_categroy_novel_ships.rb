class CreateRecommendCategroyNovelShips < ActiveRecord::Migration
  def change
    create_table :recommend_category_novel_ships do |t|
      t.integer :novel_id
      t.integer :recommend_category_id
    
      t.timestamps
    end
    add_index :recommend_category_novel_ships, :novel_id
    add_index :recommend_category_novel_ships, :recommend_category_id
  end
end
