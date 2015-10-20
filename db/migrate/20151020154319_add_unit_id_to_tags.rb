class AddUnitIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :unit_id, :integer
    add_index :tags, :unit_id
  end
end
