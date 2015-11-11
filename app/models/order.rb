class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  
  validates_presence_of :rented_on, :refunded_on, :item_id, :user_id
  
  before_create :generate_order_no
  def generate_order_no
    self.order_no = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
  end
end
