class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :creator_id, :null => false
      t.integer :actor_id,   :null => false
      t.integer :messages_count, default: 0

      t.timestamps
    end
    add_index :chats, :creator_id
    add_index :chats, :actor_id
  end
end
