module V1
  class Tags < Grape::API
    resource :tags do
      desc '获取所有的Tags'
      get do
        @tags = Tag.sorted.order('id desc')
        render_json(@tags, V1::Entities::Tag)
      end # end get /tags
    end # end resource
  end
end