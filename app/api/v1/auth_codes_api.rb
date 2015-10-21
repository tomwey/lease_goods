module V1
  class AuthCodesAPI < Grape::API
    resource :auth_codes do
      desc "获取验证码"
      params do
        requires :mobile, type: String, desc: "手机号"
      end
      post :fetch do
        
        mobile = params[:mobile].to_s
        
        ###### 手机号检测
        unless check_mobile(mobile)
          return render_error(100, "不正确的手机号")
        end
        ###### end 
        
        # 1分钟内多次发送验证码短信检测
        key = "#{mobile}_key".to_sym
        if session[key] and ( ( Time.now.to_i - session[key].to_i ) < ( 60 + rand(3) ) )
          return render_error(101, "同一手机号1分钟内只能获取一次验证码，请稍后重试")
        end
        session[key] = Time.now.to_i
        ###### end
        
        # 同一手机一天最多获取5次验证码
        log = AuthCodeLog.where('mobile = ?', mobile).first
        if log.blank?
          dt = 0
          log = AuthCodeLog.create!(mobile: mobile, first_sent_at: Time.now)
        else
          dt = Time.now.to_i - log.first_sent_at.to_i
          
          if dt > 24 * 3600 # 超过24小时重置发送记录
            log.send_total = 0
            log.first_sent_at = Time.now
            log.save!
          else
            # 24小时以内
            if log.send_total.to_i == 5 # 已经发送了5次
              return render_error(102, "同一手机号24小时内只能获取5次验证码，请稍后再试")
            end
          end
        end
        ###### end
        
        # 获取验证码并发送
        code = AuthCode.where('mobile = ? and activated_at is null', mobile).first
        if code.blank?
          code = AuthCode.create!(mobile: mobile)
        end
        
        if code.blank?
          return render_error(103, "验证码生成错误，请重试")
        end
        
        result = send_sms(mobile, "您的验证码是#{code.code}【#{Setting.app_name}】", "获取验证码失败")
        if result['code'].to_i == -1
          # 发送失败，更新每分钟发送限制
          session.delete(key)
        end
        if result['code'].to_i == 0
          # 发送成功，更新发送日志
          log.update_attribute(:send_total, log.send_total + 1)
        end
        result
        ###### end
      end # end post 
    end # end resource auth_codes
  end
end