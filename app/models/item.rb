class Item < ActiveRecord::Base
  
  attr_accessor :is_favorited
  
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  set_rgeo_factory_for_column :location, GEO_FACTORY
    
  belongs_to :tag
  belongs_to :user, counter_cache: true
   
  has_many :photos, dependent: :destroy
  
  validates :title, :tag_id, :user_id, :fee, :deposit, :location, :photos, presence: true
  validates :fee, :deposit, format: { with: /\d+/, message: "必须是整数" }
  validates :fee, :deposit, numericality: { greater_than_or_equal_to: 0 }
  
  scope :no_delete, -> { where(visible: true) }
  
  # 产品详情查看统计
  def add_visit
    self.class.increment_counter(:hits, self.id)
  end
  
  # 格式化位置坐标
  def format_location
    if location.blank?
      ""
    else
      "#{location.x},#{location.y}"
    end
  end
  
  # 格式化租金单价
  def format_fee
    "#{fee}#{tag.unit_name}"
  end
  
  # 获取第一张图片
  def first_thumb_image
    if photos.empty?
      ""
    else
      photos.order('id asc').first.image_url(:thumb)
    end
  end
  
end
