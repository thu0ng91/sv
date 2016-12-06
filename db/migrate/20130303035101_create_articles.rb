class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :novel_id
      t.text :text
      t.string :link
      t.string :title
      t.string :subject
      t.timestamps
    end
    add_index :articles, :novel_id
  end
end
