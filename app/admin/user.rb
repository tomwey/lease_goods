ActiveAdmin.register User do

  permit_params :mobile, :nickname, :avatar
  
  index do
    selectable_column
    id_column
    column :mobile
    column "Token", :private_token
    column :nickname
    column '头像' do |user|
      image_tag user.avatar.url(:large)
    end
    column :verified
    column "收藏的产品ID", :favorite_item_ids
    column "粉丝ID", :follower_ids
    column "关注的用户ID", :following_ids
    
    actions defaults: false do |user|
      item "编辑", edit_admin_user_path(user)
    end
      
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
