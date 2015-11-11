class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :order_no
      t.integer :item_id,  :null => false
      t.string :note
      t.date :rented_on,   :null => false
      t.date :refunded_on, :null => false
      t.integer :user_id,  :null => false
      t.string :state

      t.timestamps
    end
    add_index :orders, :order_no, unique: true
    add_index :orders, :item_id
    add_index :orders, :user_id
  end
end
