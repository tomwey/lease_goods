class CreateAuthCodes < ActiveRecord::Migration
  def change
    create_table :auth_codes do |t|
      t.string :code, limit: 6
      t.string :mobile
      t.datetime :activated_at

      t.timestamps
    end
    add_index :auth_codes, :code
    add_index :auth_codes, :mobile
  end
end
