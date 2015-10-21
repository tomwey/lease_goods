class CreateAuthCodeLogs < ActiveRecord::Migration
  def change
    create_table :auth_code_logs do |t|
      t.string :mobile
      t.integer :send_total, default: 0
      t.datetime :first_sent_at

      t.timestamps
    end
    add_index :auth_code_logs, :mobile, unique: true
  end
end
