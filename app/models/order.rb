class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  
  # has_many :actions
  
  # attr_accessor :actions
  
  ACTIONS = %W(confirm cancel rent refund comment)
  ACTION_INTROS = %W(确认订单 取消订单 确认出租 确认归还 评价)
  
  validates_presence_of :rented_on, :refunded_on, :item_id, :user_id
  
  before_create :generate_order_no
  def generate_order_no
    self.order_no = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
  end
  
  after_create :notify_seller
  def notify_seller
    # PushService.push('您收到一个订单，快去确认订单吧')
    Message.create!(content: '您收到一个订单，快去确认订单吧', to: %W(#{item.user.id}))
    # 订单超过24小时，系统自动取消
    SystemCancelOrderJob.set(wait: 24.hours).perform_later(self.id)
  end
  
  def not_allow_for?(action_sym, is_seller)
    case action_sym
    when :confirm then (can_confirm? and is_seller) # 卖家确认订单
    when :cancel then can_cancel?
    when :rent then (can_rent? and is_seller) # 卖家确认出租
    when :refund then (can_refund? and is_seller) # 卖家确认归还
    when :comment then (can_comment? and not is_seller) # 买家评论
    else false
    end
  end
  
  def actions_for(user)
    actions = []
    
    is_seller = user.is_seller?(item)
    Order::ACTIONS.each_with_index do |action, idx|
      
      flag = self.send("can_#{action}?")
      if action != 'cancel' or action != 'comment'
        flag = flag && is_seller
      end
      
      if action == 'comment' && !is_seller
        flag = true
      end
      
      if flag
        action_hash = {}
        action_hash[:action] = action
        action_hash[:action_name] = Order::ACTION_INTROS[idx]
        actions << action_hash
      end
      
    end
    
  end
  
  # 显示state_name
  def state_name
    case state.to_sym
    when :pending then '待确认'
    when :confirmed then '已确认'
    when :canceled then '已取消'
    when :renting then '租用中'
    when :refunded then '已归还'
    when :commented then '已评价'
    else ''
    end
  end
  
  # 状态机
  state_machine initial: :pending do # 默认为待定状态，此状态买家已经付款到平台
    state :confirmed # 订单被卖家确认
    state :canceled  # 订单已被取消，卖家和买家都有可能取消
    state :renting   # 租用中
    state :refunded  # 已归还
    state :commented # 已评价
    
    # 卖家确认订单
    after_transition :pending => :confirmed do |order,transition|
      # 通知买家，卖家已经接受了您的订单
      Message.create!(content: '卖家已经接受了您的订单', to: %W(#{self.user_id}))
    end
    event :confirm do
      transition :pending => :confirmed
    end
    
    # 取消订单，卖家，买家，系统都可能取消订单
    after_transition :pending => :canceled do |order,transition|
      # 订单被取消后，退还卖家的租金以及押金
      user.update_balance(self.total_price + self.deposit, '退还租金和押金')
    end
    event :cancel do
      transition :pending => :canceled
    end
    
    # 卖家线下与买家确认该产品出租
    after_transition :confirmed => :renting do |order,transition|
      # 通知买家，卖家已经确认了您的出租
      Message.create!(content: '卖家已经确认了您的出租', to: %W(#{self.user_id}))
    end
    event :rent do
      transition :confirmed => :renting
    end
    
    # 卖家确认归还产品
    after_transition :renting => :refunded do |order,transition|
      # 打款给卖家以及退还押金给买家
      User.transition do
        user.update_balance(self.deposit, '退还押金') # 退化押金给买家
        item.user.update_balance(self.total_price, '支付租金') # 打款给卖家
      end
      # 通知买家，卖家确认归还产品
      Message.create!(content: '卖家确认归还产品', to: %W(#{self.user_id}))
    end
    event :refund do
      transition :renting => :refunded
    end
    
    # 买家评价
    event :comment do
      transition :refunded => :commented
    end
    
  end # end state machine
  
end
