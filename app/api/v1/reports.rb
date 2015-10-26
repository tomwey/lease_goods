module V1
  class Reports < Grape::API
    resource :reports do
      desc "举报产品"
      params do
        requires :token,   type: String,  desc: "用户认证Token"
        requires :item_id, type: Integer, desc: "产品ID"
        requires :content, type: String,  desc: "举报内容"
      end
      post :create do
        user = authenticate!
        
        item = Item.find_by_id(params[:item_id])
        if item.blank?
          return render_error(4004, "没有该产品")
        end
        
        Report.create!(content: params[:content], user_id: user.id, item_id: item.id)
        
        render_json_no_data
      end # end post create
    end # end reports resource
  end
end