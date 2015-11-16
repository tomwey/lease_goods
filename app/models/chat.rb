class Chat < ActiveRecord::Base
  
  attr_accessor :unread_count, :friend
  
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id' # 会话创建者
  belongs_to :actor,   class_name: 'User', foreign_key: 'actor_id'   # 会话参与者
  belongs_to :item
  
  has_many :messages, dependent: :destroy
  
  validates_presence_of :creator_id, :actor_id
  
  def unread_count_for_user(user)
    self.unread_count = user.unread_count_for_chat(self)
     #messages.where('unread = ? and to = ?', true, user.id).count
  end
  
  def fetch_friend_for_user(user)
    self.friend = user.id == self.creator_id ? self.actor : self.creator
  end
  
  def latest_message
    messages.order('id desc').first
  end
end
