class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :from
      t.integer :to
      t.boolean :unread, default: true
      t.integer :chat_id

      t.timestamps
    end
    add_index :messages, :chat_id
    add_index :messages, :from
    add_index :messages, :to
  end
end
