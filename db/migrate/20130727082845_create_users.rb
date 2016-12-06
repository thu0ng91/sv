class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :registration_id
      t.text :read_novels

      t.timestamps
    end
  end
end
