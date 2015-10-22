class AddHitsToItems < ActiveRecord::Migration
  def change
    add_column :items, :hits, :integer, default: 0
  end
end
