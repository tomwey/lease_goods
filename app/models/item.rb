class Item < ActiveRecord::Base
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  set_rgeo_factory_for_column :location, GEO_FACTORY
  
  belongs_to :tag
end
