class Item < ActiveRecord::Base
  # include PgSearch # 加入全文检索功能
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  mapping do
    indexes :id, type: 'integer'
    indexes :tag_id, type: 'integer'
    indexes :tag_name
    indexes :title#, boost: 10
    indexes :placement
    indexes :intro
  end
  
  attr_accessor :is_favorited
  
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  set_rgeo_factory_for_column :location, GEO_FACTORY
    
  belongs_to :tag
  belongs_to :user, counter_cache: true
   
  has_many :photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  validates :title, :tag_id, :user_id, :fee, :deposit, :location, :photos, presence: true
  validates :fee, :deposit, format: { with: /\d+/, message: "必须是整数" }
  validates :fee, :deposit, numericality: { greater_than_or_equal_to: 0 }
  
  scope :no_delete, -> { where(visible: true) }
  # 通过经纬度查询一定范围内的数据，range单位是米
  scope :select_with_location, -> (longitude, latitude, range) { 
    select("items.*, st_distance(location, 'point(#{longitude} #{latitude})') as distance").
    where("st_dwithin(location, 'point(#{longitude} #{latitude})', #{range})") }
  
  # 全文检索scope
  # pg_search_scope :search, :against => {
  #   :title => 'A',
  #   :placement => 'B',
  #   :intro => 'C',
  # },
  # :using => {
  #   :tsearch => { :dictionary => "lease_goods_zhcfg", :negation => true }
  # }
  # scope :search, -> (keyword) { order('id desc') }
  
  def self.search(params)
    size = params[:size].to_i
    size = size.zero? ? 15 : size
        
    tire.search(load: true, page: params[:page], per_page: [size, 100].min) do
      query { string params[:keyword] } if params[:keyword].present?
      sort do |t|
        if params[:sort]
          params[:sort].split(',').each do |s|
            sv = s.split(' ')
            t.by sv.first.to_sym, order: sv.last.to_sym
          end
        end
      end
    end
  end
  
  def to_indexed_json
    to_json(methods: [:tag_name])
  end
  
  # 排序
  def self.sort_by_value(value)
    if value.blank?
      order('id DESC')
    else
      order("#{value}")
    end
  end
  
  # 产品详情查看统计
  def add_visit
    self.class.increment_counter(:hits, self.id)
  end
  
  # 格式化位置坐标
  def format_location
    if location.blank?
      ""
    else
      "#{location.x},#{location.y}"
    end
  end
  
  # 格式化租金单价
  def format_fee
    "#{fee}#{tag.try(:unit_name)}"
  end
  
  # 获取第一张图片
  def first_thumb_image
    if photos.empty?
      ""
    else
      photos.order('id asc').first.image_url(:thumb)
    end
  end
  
  # 获取第一条评论
  def first_comment
    comments.order('id desc').first
  end
  
  def tag_name
    tag.try(:name)
  end
  
  # 获取评分
  def rate
    stars = comments.to_a.sum(&:star)
    return 0.0 if comments_count == 0
    format("%.1f",(Float(stars) / comments_count)).to_f
  end
  
  # 软删除
  def delete!
    self.visible = false
    self.save!
  end
  
  # 取消删除
  def restore!
    self.visible = true
    self.save!
  end
  
end
