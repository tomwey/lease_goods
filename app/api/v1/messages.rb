module V1
  class Messages < Grape::API
    
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
    
    resource :messages do
      # 发送消息
      desc "发送聊天消息"
      params do
        requires :token, type: String, desc: "用户认证Token"
        requires :content, type: String, desc: "消息内容"
        requires :receiver_id, type: Integer, desc: "接收消息的用户ID"
        optional :item_id, type: Integer, desc: "咨询的某个产品ID, 考虑到以后接口通用，暂时把这个参数设置成可选"
      end
      post :send do
        sender = authenticate!
        # 检查非法
        if sender.id.to_i == params[:receiver_id].to_i
          return render_error(-4, "您不能跟自己聊天")
        end
        # 开启会话
        chat = Chat.where('item_id = :item_id and ( (creator_id = :id1 and actor_id = :id2) or (creator_id = :id2 and actor_id = :id1) )', item_id: params[:item_id], id1: sender.id, id2: params[:receiver_id]).first_or_create
        if chat.blank?
          return render_error(-5, "开启聊天会话失败")
        end
        # 发送消息
        msg = Message.create!(from: sender.id, to: params[:receiver_id], content: params[:content], chat_id: chat.id)
        render_json(msg, V1::Entities::Message)
      end # end post send
      
      # 获取未读消息条数
      desc "获取未读消息条数"
      params do
        requires :token, type: String, desc: "用户认证Token"
      end
      get :unread_count do
        user = authenticate!
      end # end get unread_count
      
      # 获取所有的会话
      desc "获取所有的消息会话列表"
      params do
        requires :token, type: String, desc: "用户认证Token"
      end  
      get :list do
        user = authenticate!
        chats = Chat.includes(:messages).where('creator_id = :user_id or actor_id = :user_id', user_id: user.id).order('id desc')
        
        # 计算未读的消息
        chats.each do |chat|
          chat.unread_count_for_user(user)
          chat.fetch_friend_for_user(user)
        end
        
        render_collection(chats, V1::Entities::Chat)
        
      end # end get /
      
      # 读某个会话下面的消息
      desc "读某个会话下面的消息"
      params do
        requires :token, type: String, desc: "用户认证Token"
        requires :friend_id, type: Integer, desc: "消息会话列表中返回的friend用户id"
        use :pagination
      end
      get :read do
        user = authenticate!
        
        chat = Chat.where('( creator_id = :id1 and actor_id = :id2 ) or ( creator_id = :id2 and actor_id = :id1 )', id1: user.id, id2: params[:friend_id]).first
        if chat.blank?
          return render_error(4004, '未找到该会话')
        end
        
        @messages = chat.messages.order('id asc')
        if params[:page]
          @messages = @messages.paginate page: params[:page], per_page: page_size
        end
        
        # 将未读消息标记为已读
        @messages.where(to: user.id).update_all(unread: false)
        
        # 返回数据
        render_collection(@messages, V1::Entities::Message)
          
      end # end read
      
    end # end messages resource
    
    # resource :chats do
    #   # 获取所有的会话
    #   desc "获取所有的会话"
    #   params do
    #     requires :token, type: String, desc: "用户认证Token"
    #   end
    #   get do
    #     user = authenticate!
    #     chats = Chat.includes(:messages).where('creator_id = :user_id or actor_id = :user_id', user_id: user.id).order('id desc')
    #
    #     # 计算未读的消息
    #     chats.each do |chat|
    #       chat.unread_count_for_user(user)
    #       chat.fetch_friend_for_user(user)
    #     end
    #
    #     if chats.empty?
    #       render_empty_collection
    #     else
    #       render_json(chats, V1::Entities::Chat)
    #     end
    #   end # end get /
    #
    #   # 读某个会话下面的消息
    #   desc "读某个会话下面的消息"
    #   params do
    #     requires :token, type: String, desc: "用户认证Token"
    #     use :pagination
    #   end
    #   get '/:chat_id/read' do
    #     user = authenticate!
    #
    #     chat = Chat.where('id = :id and ( creator_id = :user_id or actor_id = :user_id )', id: params[:chat_id], user_id: user.id).first
    #     if chat.blank?
    #       return render_error(4004, '未找到该会话')
    #     end
    #
    #     @messages = chat.messages.order('id asc')
    #     if params[:page]
    #       @messages = @messages.paginate page: params[:page], per_page: page_size
    #     end
    #
    #     # 将未读消息标记为已读
    #     Message.where(to: user.id).update_all(unread: false)
    #
    #     # 返回数据
    #     if @messages.empty?
    #       render_empty_collection
    #     else
    #       render_json(@messages, V1::Entities::Message)
    #     end
    #   end # end read
    #
    # end # end chats resource
    
  end
end