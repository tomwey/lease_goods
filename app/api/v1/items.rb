module V1
  class Items < Grape::API
    
    resource :items do
      desc "发布一个产品"
      params do
        requires :title,    type: String,  desc: "产品标题"
        requires :tag_id,   type: Integer, desc: "类别id"
        requires :token,    type: String,  desc: "用户认证Token"
        requires :fee,      type: Integer, desc: "产品的租金, 不带单位，整数，例如：20"
        requires :deposit,  type: Integer, desc: "产品保证金，不带单位，整数，例如：1000"
        requires :location, type: String,  desc: "发布产品的位置坐标，值格式为：(经度,纬度)用英文逗号分隔，例如：120.3454,20.3045"
        requires :placement,type: String,  desc: "发布产品所在位置逆向编码的建筑物名称, 比如小区或学校的名字，例如：绿地世纪城"
        
        optional :intro,    type: String,  desc: "产品新旧程度描述，例如：95成新"
        optional :note,     type: String,  desc: "备注"
      end
      post :create do
        authenticate!
        
      end # end create
      
    end # end resource items
    
  end
end
