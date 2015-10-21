class Photo < ActiveRecord::Base
  belongs_to :item
  
  mount_uploader :image, PhotoUploader
  
end
