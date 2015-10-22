class Photo < ActiveRecord::Base
  belongs_to :item
  
  validates :image, presence: true
  
  mount_uploader :image, PhotoUploader
  
  # 格式化图片
  def image_url(size = :thumb)
    if image.blank?
      ""
    else
      image.url(size)
    end
  end
  
end
