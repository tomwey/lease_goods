class Message < ActiveRecord::Base
  belongs_to :chat, counter_cache: true
  belongs_to :sender, class_name: 'User', foreign_key: 'from'
  belongs_to :receiver, class_name: 'User', foreign_key: 'to'
  validates_presence_of :content
  
  after_create :deliver_message
  def deliver_message
    
  end
  
end
