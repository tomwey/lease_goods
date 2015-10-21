class Tag < ActiveRecord::Base
  scope :sorted, -> { order('sort desc') }
  
  belongs_to :unit
  
  def unit_name
    unit.try(:name) || ""
  end
  
end
