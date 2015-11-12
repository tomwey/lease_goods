module V1
  class Orders < Grape::API
    
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
    
    resource :orders do
      # 下单
      desc "下单"
      params do
        requires :token, type: String, desc: "用户认证Token"
        requires :item_id, type: Integer, desc: "产品ID"
        requires :rented_on, type: String, desc: "起租日期，格式为：yyyy-MM-dd，例如：2015-03-01"
        requires :refunded_on, type: String, desc: "归还日期，格式同rented_on字段的值"
        optional :total_price, type: Integer, desc: "租金总价，建议客户端计算好后传过来"
        optional :deposit, type: Integer, desc: "押金，建议客户端把该产品的押金传过来"
        optional :note, type: String, desc: "备注"
      end
      post :create do
        user = authenticate!
        
        item = Item.find_by(id: params[:item_id])
        if item.blank?
          return render_error(4004, '该产品不存在')
        end
        
        if user == item.user
          return render_error(6001, '您不能租自己的产品')
        end
        
        # 计算总价
        days = (Date.parse(params[:refunded_on]) - Date.parse(params[:rented_on]).to_i
        if days < 0
          return render_error(-1, '不正确的归还日期，必须大于或等于起租日期')
        end
        if days == 0 # 当天借，当天还，算一天
          days = 1
        end
        
        # 余额检测
        total = days * item.fee
        if user.balance < total
          return render_error(6002, '您的余额不足，请充值')
        end
        
        ActiveRecord::Base.transaction do
          Order.create!(item_id: item.id, 
                                    user_id: user.id, 
                                    refunded_on: Date.parse(params[:refunded_on]),
                                    rented_on: Date.parse(params[:rented_on]),
                                    total_price: total,
                                    deposit: item.deposit,
                                    note: params[:note])
                                    
          user.update_balance(-total, '支付订单')
        end
        
        render_json_no_data
        
      end # end post create
      
      # 获取订单
      desc "获取订单"
      params do
        requires :token, type: String, desc: "用户认证Token"
        requires :type,  type: Integer, desc: "订单数据类别，0表示我从别人那租的订单，1表示我租给别人的订单"
        use :pagination
      end
      get :list do
        user = authenticate!
        
        type = params[:type].to_i
        
        if type != 0 and type != 1
          return render_error(-1, '不正确的type值')
        end
        
        if type == 0
          @orders = user.orders.includes(:item).order('id desc')
        else
          @orders = Order.includes(:item).where('items.user_id = ?', user.id).order('id desc')
        end
        
        if params[:page]
          @orders = @orders.paginate page: params[:page], per_page: page_size
        end
        
        render_collection(@orders, V1::Entities::Order)
      end # end get list
      
    end # end resource order
    
    resource :order do
      # 操作订单
      desc "操作订单"
      params do
        requires :token, type: String, desc: "用户认证Token"
        requires :order_no, type: String, desc: "订单号"
        requires :action, type: String, desc: "操作方式，值为：/orders/list接口里面返回的actions数组里面的action字段"
      end
      post :handle do
        user = authenticate!
        
        order = user.orders.find_by(order_no: params[:order_no])
        if order.blank?
          return render_error(4004, '该订单不存在')
        end
        
        if not Order::ACTIONS.include?(params[:action].to_s)
          return render_error(-1, '不正确的action参数值')
        end
        
        if order.send(params[:action].to_sym)
          render_json_no_data
        else
          render_error(6003, '操作订单失败')
        end
        
      end # end post handle
      
    end # end resource
    
  end
end