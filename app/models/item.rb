class Item < ActiveRecord::Base
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  set_rgeo_factory_for_column :location, GEO_FACTORY
    
  belongs_to :tag
  belongs_to :user, counter_cache: true
   
  has_many :photos, dependent: :destroy
  
  validates :title, :tag_id, :user_id, :fee, :deposit, :location, :photos, presence: true
  validates :fee, :deposit, format: { with: /\d+/, message: "必须是整数" }
  validates :fee, :deposit, numericality: { greater_than_or_equal_to: 0 }
  
  
end
