module V1
  class Items < Grape::API
    
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
    
    resource :items do
      
      desc "获取当前位置附近的产品，如果传了搜索关键字参数，那么会返回与关键字匹配的产品，支持排序和分页"
      params do 
        requires :location, type: String, desc: "当前经纬度坐标，值格式为：经度,纬度，例如：120.123455,34.098763"
        optional :range, type: Integer, default: 2000, desc: "覆盖的范围，以米为单位，默认为2000米范围内的"
        optional :tag_id, type: Integer, desc: "类别ID，如果该参数不传，那么取所有类别的数据"
        optional :sort, type: String, desc: "排序方式，支持多个字段排序；值格式为：字段1 asc(升序),字段2 desc(降序),...，例如：id asc,likes_count desc,..."
        optional :keyword, type: String, desc: "搜索关键字，目前暂时支持对产品标题的搜索"
        use :pagination
      end
      get :nearby do
        range = params[:range].to_i.zero? ? 2000 : params[:range].to_i
        
        # location 参数检测
        values = params[:location].split(',')
        if values.size != 2
          return render_error(-1, "不正确的location参数值，值例如：120.123455,34.098763")
        end
        
        longitude = params[:location].split(',').first.to_s
        latitude  = params[:location].split(',').last.to_s
        
        tag_id = params[:tag_id]
        # 类别检测
        if tag_id.blank?
          @items = Item.all
        else
          tag = Tag.find_by(id: tag_id.to_i)
          if tag.blank?
            return render_error(4004, "没有该类别")
          end
          
          @items = Item.where(tag_id: tag.id)
        end
        
        @items = @items.includes(:tag, :photos).no_delete.select_with_location(longitude, latitude, range)
        
        # 搜索
        if params[:keyword]
          @items = @items.search("#{params[:keyword]}")
        end
        
        # 排序
        @items = @items.sort_by(params[:sort])
        
        # 分页处理
        if params[:page]
          @items = @items.paginate page: params[:page], per_page: page_size
        end
        
        if @items.empty?
          render_empty_collection
        else
          render_json(@items, V1::Entities::Item)
        end
        
      end # end get nearby
      
      desc "获取产品详情"
      params do
        optional :token, type: String, desc: "用户认证Token"
      end
      get '/show/:item_id' do
        item = Item.includes(:tag, :user, :photos, :comments).find_by(id: params[:item_id])
        if item.blank?
          return render_error(4004, "没有该产品")
        end
        
        if params[:token]
          user = User.find_by(private_token: params[:token])
          item.is_favorited = user.favorited_item?(item.id) if user.present?
        end
        
        render_json(item, V1::Entities::ItemDetail)
        
      end # end get show/123
      
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
      
      desc "收藏产品"
      params do
        requires :token, type: String, desc: "收藏产品"
      end
      post '/:item_id/favorite' do
        user = authenticate!
        
        item = Item.find_by(id: params[:item_id])
        if item.blank?
          return render_error(4004, "要收藏的产品不存在")
        end
        
        if user.favorited_item?(item.id)
          return render_error(5000, "您已经收藏过该产品")
        end
        
        if user.favorite_item(item.id)
          render_json_no_data
        else
          render_error(5001, "收藏产品失败")
        end
      end # end post favorite 
      
      desc "取消收藏产品"
      params do
        requires :token, type: String, desc: "收藏产品"
      end
      post '/:item_id/unfavorite' do
        user = authenticate!
        
        item = Item.find_by(id: params[:item_id])
        if item.blank?
          return render_error(4004, "要取消收藏的产品不存在")
        end
        
        if not user.favorited_item?(item.id)
          return render_error(5000, "您还未收藏该产品")
        end
        
        if user.unfavorite_item(item.id)
          render_json_no_data
        else
          render_error(5001, "取消收藏产品失败")
        end
      end # end post unfavorite 
      
    end # end resource items
    
  end
end
