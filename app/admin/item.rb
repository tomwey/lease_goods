ActiveAdmin.register Item do
  menu :priority => 2
  # permit_params :title, :tag_id, :user_id, :fee, :deposit, :intro, :note,
  
  actions :index, :show
  
  filter :title
  filter :fee
  filter :deposit
  filter :tag
  filter :placement
  filter :comments_count
  
  scope :all, :default => true
  scope :available do |items|
    items.where(visible: true)
  end
  
  form partial: 'form'
  
  index do 
    selectable_column
    column("ID", :id) { |item| link_to item.id, admin_item_path(item) }
    column("Icon") { |item| image_tag item.first_thumb_image, size: '64x64' }
    column("标题", :title, sortable: false)
    column("Tag", :tag) #{ |item| item.tag.try(:name)}
    column("所属用户", :user, sortable_id: :user_id) { |item| link_to item.user.try(:nickname), admin_user_path(item.user) }
    column("租金", :fee)
    column("保证金", :deposit)
    column("简介", :intro, sortable: false)
    column("位置坐标", :location)
    column("地址", :placement, sortable: false)
    column("发布时间", :created_at)
    column("查看次数", :hits)
    column("评论数", :comments_count)
    
    actions defaults: false do |item|
      if item.visible
        item "删除", delete_admin_item_path(item), method: :put
      else
        item "恢复", restore_admin_item_path(item), method: :put
      end
      
    end
    
  end
  
  sidebar :help, only: :index do
    "Need help? Email us at help@example.com"
  end
  
  sidebar :help do
    ul do
      li "Second List First Item"
      li "Second List Second Item"
    end
  end
  
  # 自定义Actions
  batch_action :delete, priority: 1  do |ids|
    batch_action_collection.find(ids).each do |item|
      item.delete!
    end
    redirect_to collection_path, alert: "删除成功"
  end
  
  batch_action :restore, priority: 2 do |ids|
    batch_action_collection.find(ids).each do |item|
      item.restore!
    end
    redirect_to collection_path, alert: "恢复成功"
  end
  
  member_action :delete, method: :put do 
    resource.delete!
    redirect_to admin_items_path, notice: "已经删除"
  end
  
  member_action :restore, method: :put do 
    resource.restore!
    redirect_to admin_items_path, notice: "已经恢复"
  end

end
