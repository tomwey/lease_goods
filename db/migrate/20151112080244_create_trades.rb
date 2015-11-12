class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.string :money
      t.string :intro
      t.integer :user_id
      t.integer :pay_type

      t.timestamps
    end
    add_index :trades, :user_id
  end
end
