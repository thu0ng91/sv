class CreateRecommendCategories < ActiveRecord::Migration
  def change
    create_table :recommend_categories do |t|
      t.string :name
    
      t.timestamps
    end
  end
end
