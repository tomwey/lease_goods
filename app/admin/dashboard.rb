ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  content :title => proc { I18n.t("active_admin.dashboard") } do
  
    columns do
    
      column do
        panel "最新用户" do
          table_for User.order('id desc').limit(10) do
            column('头像') { |user| image_tag user.avatar.url(:large) }
            column('昵称') { |user| link_to user.nickname, admin_user_path(user) }
          end
        end
      end # end Recent Users
      
      column do
        panel "最新产品" do
          table_for Item.order('id desc').limit(10) do 
            column('Icon') { |item| image_tag item.first_thumb_image, size: '60x60' }
            column(:title) { |item| link_to item.title, admin_item_path(item) }
          end
        end
      end # end Recent Items
    
    end
    
    columns do
      column do
        div do
          br
          # text_node %{<iframe src="https://rpm.newrelic.com/public/charts/6VooNO2hKWB" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
        end
      end # end charts 
      
      column do
        panel "最近订单" do
        end
      end # end Recent Orders
    end
    
  end # end contents
  
end
