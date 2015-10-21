module V1
  class Users < Grape::API
    
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
        
        user = User.new(mobile: params[:mobile], avatar: params[:avatar_url], nickname: params[:nickname])
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
        
      end # end post update_profile
      
    end # end resource user
  end
end

# t.string :mobile,         :null => false
# t.string :private_token
# t.string :nickname,       :null => false
# t.string :avatar