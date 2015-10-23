class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, counter_cache: true
  
  validates :body, presence: true
  validates :star, inclusion: { in: 1..5, message: "必须是1到5的整数" }
  
end
