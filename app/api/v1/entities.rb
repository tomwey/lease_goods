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
    class UserNoToken < Base
      expose :nickname, format_with: :null
      expose :mobile, format_with: :null
      expose :real_avatar_url, as: :avatar
    end # end User
    
    # User
    class User < Base
      expose :private_token, as: :token, format_with: :null
      expose :nickname, format_with: :null
      expose :mobile, format_with: :null
      expose :real_avatar_url, as: :avatar
    end # end User
    
  end
end