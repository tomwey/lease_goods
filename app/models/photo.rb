class Photo < ActiveRecord::Base
  belongs_to :item
  
  validates :image, presence: true
  
  mount_uploader :image, PhotoUploader
  
end
