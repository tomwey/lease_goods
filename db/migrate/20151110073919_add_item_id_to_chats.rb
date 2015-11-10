class AddItemIdToChats < ActiveRecord::Migration
  def change
    add_column :chats, :item_id, :integer
    add_index :chats, :item_id
  end
end
