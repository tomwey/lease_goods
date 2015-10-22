module V1
  class Items < Grape::API
    
    resource :items do
      desc "发布一个产品" do
        detail "注意：此接口还必须传入多张图片，参数的名字以：photo为前缀，后面跟数字，例如：photo0, photo1, photo2..."
      end
      params do
        requires :title,    type: String,  desc: "产品标题"
        requires :tag_id,   type: Integer, desc: "类别id"
        requires :token,    type: String,  desc: "用户认证Token"
        requires :fee,      type: Integer, desc: "产品的租金, 不带单位，整数，例如：20"
        requires :deposit,  type: Integer, desc: "产品保证金，不带单位，整数，例如：1000"
        requires :location, type: String,  desc: "发布产品的位置坐标，值格式为：(经度,纬度)用英文逗号分隔，例如：120.3454,20.3045"
        requires :placement,type: String,  desc: "发布产品所在位置逆向编码的建筑物名称, 比如小区或学校的名字，例如：绿地世纪城"
        optional :photo0,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :photo1,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :photo2,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :photo3,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :photo4,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :photo5,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :photo6,   type: Rack::Multipart::UploadedFile, desc: "产品图片"
        optional :intro,    type: String,  desc: "产品新旧程度描述，例如：95成新"
        optional :note,     type: String,  desc: "备注"
      end
      post :create do
        user = authenticate!
        
        tag = Tag.find_by(id: params[:tag_id])
        if tag.blank?
          return render_error(4004, '不正确的类别ID')
        end
        
        item = Item.new(title: params[:title], 
                        tag_id: tag.id, 
                        user_id: user.id,
                        fee: params[:fee], 
                        deposit: params[:deposit],
                        placement: params[:placement],
                        intro: params[:intro],
                        note: params[:note])
        
        # 设置位置                
        longitude = params[:location].split(',').first
        latitude  = params[:location].split(',').last
        item.location = 'POINT(' + "#{longitude}" + ' ' + "#{latitude}" + ')'
        
        # 设置图片
        params.each do |key, value|
          if key.to_s =~ /photo\d+/
            photo = Photo.new(image: value)
            item.photos << photo
          end
        end
        
        # 保存
        if item.save
          render_json_no_data
        else
          render_error(3001, item.errors.full_messages.join(','))
        end
        
      end # end create
      
    end # end resource items
    
  end
end
