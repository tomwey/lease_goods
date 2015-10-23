class AddStarToComments < ActiveRecord::Migration
  def change
    add_column :comments, :star, :integer
  end
end
