class User < ActiveRecord::Base
  
  has_many :items, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8|7][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, 
  length: { is: 11 }, :uniqueness => true
  
  mount_uploader :avatar, AvatarUploader
  
  # 生成默认用户昵称
  before_create :generate_nickname
  def generate_nickname
    if self.nickname.blank?
      rand_string = "u" + Array.new(6){[*'0'..'9'].sample}.join
      self.nickname = rand_string
    end
  end
  
  # 成功创建用户后，生成一个认证Token
  after_create :generate_private_token
  def generate_private_token
    random_key = "#{SecureRandom.hex(10)}"
    self.update_attribute(:private_token, random_key)
    
    # if self.nickname.blank?
    #   rand_string = "u" + Array.new(6){[*'0'..'9'].sample}.join
    #   self.update_attribute(:nickname, rand_string)
    # end
    
  end
  
  # 收藏产品
  def favorite_item(item_id)
    return false if item_id.blank?
    
    item_id = item_id.to_i
    
    return false if favorited_item?(item_id)
    
    self.favorite_item_ids << item_id
    favorite_item_ids_will_change! # 告诉ActiveRecord数组的值已经改变
    self.save!
    true
  end
  
  # 是否收藏过产品
  def favorited_item?(item_id)
    favorite_item_ids.include?(item_id)
  end
  
  # 获取收藏的产品数
  def favorite_item_counts
    favorite_item_ids.size
  end
  
  # 取消收藏产品
  def unfavorite_item(item_id)
    return false if item_id.blank?
    
    item_id = item_id.to_i
    
    self.favorite_item_ids.delete(item_id)
    favorite_item_ids_will_change! # 告诉ActiveRecord数组的值已经改变
    self.save!
    true
  end
  
  # 获取头像地址
  def real_avatar_url
    if self.avatar.present?
      self.avatar.url(:big)
    else
      ""
    end
  end
  
end
