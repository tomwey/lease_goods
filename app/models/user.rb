class User < ActiveRecord::Base
  
  has_many :items, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8|7][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, 
  length: { is: 11 }, :uniqueness => true
  
  mount_uploader :avatar, AvatarUploader
  
  after_create :generate_private_token
  def generate_private_token
    random_key = "#{SecureRandom.hex(10)}"
    self.update_attribute(:private_token, random_key)
    
    if self.nickname.blank?
      rand_string = "u" + Array.new(6){[*'0'..'9'].sample}.join
      self.update_attribute(:nickname, rand_string)
    end
    
  end
  
  def real_avatar_url
    if self.avatar.present?
      self.avatar.url(:big)
    else
      ""
    end
  end
  
end
