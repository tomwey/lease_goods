module V1
  class Comments < Grape::API
    
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
    
    resource :items do
      
      desc "获取某个产品的所有评论，支持分页"
      params do
        use :pagination
      end
      get '/:item_id/comments' do
        item = Item.find_by_id(params[:item_id])
        if item.blank?
          return render_error(4004, "没有该产品")
        end
        
        @comments = item.comments.includes(:user).order('id desc')
        if params[:page]
          @comments = @comments.paginate page: params[:page], per_page: page_size
        end
        
        if @comments.empty?
          render_empty_collection
        else
          render_json(@comments, V1::Entities::CommentDetail)
        end
        
      end # end get
            
    end # end items resource
    
    resource :comments do
      
      desc "发表评论"
      params do
        requires :token,   type: String,  desc: "用户认证Token"
        requires :item_id, type: Integer, desc: "产品id"
        requires :content, type: String,  desc: "评论内容"
        optional :star,    type: Integer, desc: "评论星级，值为1到5的整数", values: [1,2,3,4,5]
      end
      post :create do
        user = authenticate!
        
        item = Item.find_by(id: params[:item_id])
        if item.blank?
          return render_error(4004, "需要评论的产品不存在")
        end
        
        if user == item.user
          return render_error(6000, "您不能评论自己的产品")
        end
        
        comment = Comment.new(body: params[:content], star: params[:star], item_id: item.id, user_id: user.id)
        if comment.save
          render_json_no_data
        else
          render_error(6001, comment.errors.full_messages.join('\n'))
        end
      end # end post create
      
    end # end comments resource
    
  end
end