class AddItemsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :items_count, :integer, default: 0
  end
end
