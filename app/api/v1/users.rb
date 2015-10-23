module V1
  class Users < Grape::API
    
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
        
    resource :account do
      desc "用户登录"
      params do
        requires :mobile, type: String, desc: "用户手机号，必须"
        requires :code,   type: String, desc: "短信验证码，必须"
      end
      post :login do
        # 手机号验证
        unless check_mobile(params[:mobile])
          return render_error(1001, "不正确的手机号")
        end
        
        # 检查验证码是否有效
        ac = AuthCode.where('mobile = ? and code = ? and activated_at is null', params[:mobile], params[:code]).first
        if ac.blank?
          return render_error(1004, "验证码无效")
        end
        
        # 快捷登录
        user = User.find_by(mobile: params[:mobile])
        if user.present?
          ac.update_attribute(:activated_at, Time.now)
          return render_json(user, V1::Entities::User)
        end
        
        user = User.new(mobile: params[:mobile])
        if user.save
          ac.update_attribute(:activated_at, Time.now)
          render_json(user, V1::Entities::User)
        else
          render_error(1005, "用户登录失败")
        end
      end # end post login
    end # end resource account
    
    resource :user do
      
      desc "获取我的个人信息"
      params do
        requires :token, type: String, desc: "用户认证Token"
      end
      get :me do
        user = authenticate!
        render_json(user, V1::Entities::User)
      end # end get /me
      
      desc "获取某个用户的信息"
      params do
        requires :user_id, type: Integer, desc: "用户ID"
      end
      get :info do
        user = User.find_by(id: params[:user_id])
        if user.blank?
          return render_empty_object
        end
        
        render_json(user, V1::Entities::UserNoToken)
      end # end get /other
      
      desc "获取我收藏的产品，支持分页"
      params do
        requires :token, type: String, desc: "用户认证Token"
        use :pagination
      end
      get :favorited_items do
        user = authenticate!
        
        @items = Item.includes(:tag).no_delete.where(id: user.favorite_item_ids).order('id desc')
        if params[:page]
          @items = @items.paginate page: params[:page], per_page: page_size
        end
        
        if @items.empty?
          render_empty_collection
        else
          if params[:page]
            render_paginate_json(@items, @items.total_entries, V1::Entities::Item)
          else
            render_json(@items, V1::Entities::Item)
          end
        end
        
      end # end get favorited_items
      
      desc "关注某个用户"
      params do
        requires :token,   type: String,  desc: "用户认证Token"
        requires :user_id, type: Integer, desc: "被关注用户的ID"
      end
      post :follow do
        user = authenticate!
        
        other = User.find_by(id: params[:user_id])
        
        if user == other
          return render_error(2001, "您不能关注您自己")
        end
        
        if user.followed?(other)
          return render_error(2001, "您已经关注了该用户")
        end
        
        if user.follow_user(other)
          render_json_no_data
        else
          render_error(2002, '关注用户失败')
        end
      end # end post follow
      
      desc "取消关注某个用户"
      params do
        requires :token,   type: String,  desc: "用户认证Token"
        requires :user_id, type: Integer, desc: "被关注用户的ID"
      end
      post :unfollow do
        user = authenticate!
        
        other = User.find_by(id: params[:user_id])
        if not user.followed_user?(other)
          return render_error(2001, "您还未关注该用户, 不能取消关注")
        end
        
        if user.unfollow_user(other)
          render_json_no_data
        else
          render_error(2002, '取消关注用户失败')
        end
      end # end post unfollow
      
      desc "获取我关注的用户，支持分页"
      params do
        requires :token, type: String, desc: "用户认证Token"
        use :pagination
      end
      get :following_users do
        user = authenticate!
        
        @users = User.where(id: user.following_ids).order('id desc')
        if params[:page]
          @users = @users.paginate page: params[:page], per_page: page_size
        end
        
        if @users.empty?
          render_empty_collection
        else
          render_json(@users, V1::Entities::UserNoToken)
        end
        
      end # end get following_users
      
      desc "获取我的粉丝，支持分页"
      params do
        requires :token, type: String, desc: "用户认证Token"
        use :pagination
      end
      get :followers do
        user = authenticate!
        
        @users = User.where(id: user.follower_ids).order('id desc')
        if params[:page]
          @users = @users.paginate page: params[:page], per_page: page_size
        end
        
        if @users.empty?
          render_empty_collection
        else
          render_json(@users, V1::Entities::UserNoToken)
        end
        
      end # end get followers
      
      desc "第三方登录绑定用户数据"
      params do
        requires :provider,    type: String, desc: "第三方登录平台名，该参数的值固定为：Sina或QQ，例如：Sina, QQ"
        requires :uid,         type: String, desc: "第三方登录平台对应的认证标识id, 例如：23129393"
        requires :mobile,      type: String, desc: "绑定的手机号"
        requires :avatar_url,  type: String, desc: "第三方登录平台返回的头像图片地址"
        requires :nickname,    type: String, desc: "第三方登录平台提供的用户昵称"
      end
      post :bind do
        authorization = Authorization.where("uid = :uid and lower(provider) = :provider", uid: params[:uid], provider: params[:provider].downcase).first
        if authorization.present?
          return render_json(authorization.user, V1::Entities::User)
        end
        
        user = User.new(mobile: params[:mobile], nickname: params[:nickname])
        user.remote_avatar_url = params[:avatar_url]
        user.authorizations << Authorization.new(uid: params[:uid], provider: params[:provider])
        
        if user.save
          render_json(user, V1::Entities::User)
        else
          render_error(1006, user.errors.full_messages.join(","))
        end
        
      end # end post bind
      
      desc "修改已经绑定的手机号"
      params do
        requires :token,  type: String,  desc: "用户认证Token"
        requires :mobile, type: String,  desc: "手机号"
        requires :code,   type: String,  desc: "短信验证码"
      end
      post :update_mobile do
        user = authenticate!
        
        # 手机号验证
        unless check_mobile(params[:mobile])
          return render_error(1001, "不正确的手机号")
        end
        
        # 检查验证码是否有效
        ac = AuthCode.where('mobile = ? and code = ? and activated_at is null', params[:mobile], params[:code]).first
        if ac.blank?
          return render_error(1004, "验证码无效")
        end
        
        user.mobile = params[:mobile]
        if user.save
          render_json(user, V1::Entities::User)
        else
          render_error(1006, user.errors.full_messages.join(","))
        end
        
      end # end post update_mobile
      
      desc "修改昵称或者头像"
      params do
        requires :token,    type: String,  desc: "用户认证Token"
        optional :nickname, type: String,  desc: "用户昵称"
        optional :avatar,   type: Rack::Multipart::UploadedFile, desc: "用户头像图片"
      end
      post :update_profile do
        user = authenticate!
        
        if params[:nickname]
          user.nickname = params[:nickname]
        end
        
        if params[:avatar]
          user.avatar = params[:avatar]
        end
        
        if user.save
          render_json(user, V1::Entities::User)
        else
          render_error(1006, user.errors.full_messages.join(","))
        end
        
      end # end post update_profile
      
    end # end resource user
  end
end

# t.string :mobile,         :null => false
# t.string :private_token
# t.string :nickname,       :null => false
# t.string :avatar