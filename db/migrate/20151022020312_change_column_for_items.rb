class ChangeColumnForItems < ActiveRecord::Migration
  def change
    rename_column :items, :location_name, :placement
  end
end
