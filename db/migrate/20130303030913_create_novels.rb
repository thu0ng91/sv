class CreateNovels < ActiveRecord::Migration
  def change
    create_table :novels do |t|
      t.string :name
      t.string :author
      t.text :description
      t.string :pic
      t.integer :category_id
      t.string  :link
      t.string  :article_num
      t.string  :last_update
      t.boolean :is_serializing
      t.boolean :is_category_recommend
      t.boolean :is_category_hot
      t.boolean :is_category_this_week_hot
      t.boolean :is_classic
      t.boolean :is_classic_action

      t.timestamps
    end
    add_index :novels, :category_id
  end
end
