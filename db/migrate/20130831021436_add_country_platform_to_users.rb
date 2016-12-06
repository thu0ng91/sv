class AddCountryPlatformToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :platform, :string
  end
end
