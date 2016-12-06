class CreateArticleTexts < ActiveRecord::Migration
  def change
    create_table :article_texts do |t|
      t.text :text, :text, :text, :limit => 65535*1.2
      t.integer :article_id
      t.timestamps
    end
    add_index :article_texts, :article_id

    remove_column :articles, :text
  end
end
