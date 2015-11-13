class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  
  # has_many :actions
  
  ACTIONS = %W(confirm cancel rent refund comment)
  
  validates_presence_of :rented_on, :refunded_on, :item_id, :user_id
  
  before_create :generate_order_no
  def generate_order_no
    self.order_no = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
  end
  
  after_create :notify_seller
  def notify_seller
    PushService.push('您收到一个订单，快去确认订单吧')
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
  
  # 状态机
  state_machine initial: :pending do # 默认为待定状态，此状态买家已经付款到平台
    state :confirmed # 订单被卖家确认
    state :canceled  # 订单已被取消，卖家和买家都有可能取消
    state :renting   # 租用中
    state :refunded  # 已归还
    state :commented # 已评价
    
    # 卖家确认订单
    event :confirm do
      transition :pending => :confirmed
    end
    
    # 取消订单，卖家，买家，系统都可能取消订单
    event :cancel do
      transition :pending => :canceled
    end
    
    # 卖家线下与买家确认该产品出租
    event :rent do
      transition :confirmed => :renting
    end
    
    # 卖家确认归还产品
    event :refund do
      transition :renting => :refunded
    end
    
    # 买家评价
    event :comment do
      transition :refunded => :commented
    end
    
  end # end state machine
  
end
