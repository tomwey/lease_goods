ActiveAdmin.register User do

  permit_params :mobile, :nickname, :avatar
  
  actions :index, :show
  
  filter :nickname
  filter :mobile
  
  scope :all, default: true
  scope :verified do |users|
    users.where(verified: true)
  end
  
  index do
    selectable_column
    column("ID", :id) { |user| link_to user.id, admin_user_path(user) }
    column :mobile, sortable: false
    column "Token", :private_token, sortable: false
    column :nickname, sortable: false
    column '头像' do |user|
      image_tag user.avatar.url(:large)
    end
    column "是否禁用" do |user|
      user.verified ? "否" : "是"
    end
    column "收藏的产品ID", :favorite_item_ids, sortable: false
    column "粉丝ID", :follower_ids, sortable: false
    column "关注的用户ID", :following_ids, sortable: false
    column "创建时间", :created_at
    
    actions defaults: false do |user|
      if user.verified
        item "禁用", block_admin_user_path(user), method: :put
      else
        item "启用", unblock_admin_user_path(user), method: :put
      end
    end
      
  end
  
  batch_action :block do |ids|
    batch_action_collection.find(ids).each do |user|
      user.block!
    end
    redirect_to collection_path, alert: "已经禁用"
  end
  
  batch_action :unblock do |ids|
    batch_action_collection.find(ids).each do |user|
      user.unblock!
    end
    redirect_to collection_path, alert: "已经启用"
  end
  
  member_action :block, method: :put do
    resource.block!
    redirect_to admin_users_path, notice: "已禁用"
  end
  
  member_action :unblock, method: :put do
    resource.unblock!
    redirect_to admin_users_path, notice: "取消禁用"
  end
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end


end
