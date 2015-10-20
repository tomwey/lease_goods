class Tag < ActiveRecord::Base
  scope :sorted, -> { order('sort desc') }
end
