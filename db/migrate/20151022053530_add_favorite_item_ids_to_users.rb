class AddFavoriteItemIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :favorite_item_ids, :integer, array: true, default: []
  end
end
