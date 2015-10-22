module V1
  class Base < Grape::API
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
  end
end