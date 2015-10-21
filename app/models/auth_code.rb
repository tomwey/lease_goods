class AuthCode < ActiveRecord::Base
  validates :mobile, presence: true
  
  before_create :generate_code
  def generate_code
    self.code = rand.to_s[2..5]
  end
  
end
