class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :content
      t.references :user, index: true
      t.references :item, index: true

      t.timestamps
    end
  end
end
