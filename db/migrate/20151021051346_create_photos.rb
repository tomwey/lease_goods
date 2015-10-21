class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :image
      t.integer :item_id

      t.timestamps
    end
    add_index :photos, :item_id
  end
end
