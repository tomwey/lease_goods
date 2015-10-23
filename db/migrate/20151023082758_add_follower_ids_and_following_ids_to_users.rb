class AddFollowerIdsAndFollowingIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :follower_ids, :integer, array: true, default: []
    add_column :users, :following_ids, :integer, array: true, default: []
  end
end
