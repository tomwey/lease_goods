module V1
  module Entities
    class Base < Grape::Entity
      format_with(:null) { |v| v.blank? ? "" : v }
      format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
      expose :id
    end
    
    # Tag
    class Tag < Base
      expose :name
      expose :unit_name, as: :unit
    end # end Tag
    
    # User
    class User < Base
      expose :private_token, as: :token, format_with: :null
      expose :nickname, format_with: :null
      expose :mobile, format_with: :null
      expose :real_avatar_url, as: :avatar
      expose :favorite_item_counts
    end # end User
    
    # Photo
    class Photo < Base
      expose :thumb_image do |model, opts|
        model.image_url(:thumb)
      end
      expose :large_image do |model, opts|
        model.image_url(:large)
      end
    end
    
    # User
    class UserNoToken < User
      unexpose :private_token
    end # end User
    
    # ItemUser
    class ItemUser < UserNoToken
      expose :items_count
    end
    
    # Item
    class Item < Base
      with_options(format_with: :null) do
        expose :title, :deposit, :placement, :intro
      end
      expose :format_fee, as: :fee
      expose :format_location, as: :location
      expose :first_thumb_image, as: :thumb_image
      expose :tag_name do |model, opts|
        model.tag.try(:name) || ""
      end
    end
    
    # ItemDetail
    class ItemDetail < Item
      unexpose :first_thumb_image
      expose :user, as: :owner, using: V1::Entities::ItemUser
      expose :photos, using: V1::Entities::Photo do |model, opts|
        model.photos.order('id asc')
      end
    end
    
  end
end