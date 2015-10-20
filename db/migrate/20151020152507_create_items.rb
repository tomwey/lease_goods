class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string  :title,     :null => false
      t.integer :tag_id,    :null => false
      t.integer :user_id,   :null => false
      t.integer :fee,       :null => false  # 租金，不带单位
      t.integer :deposit,   :null => false  # 保证金，以元为单位
      t.string  :intro                      # 东西简介，例如新旧程度的描述
      t.text    :note                       # 备注
      t.point   :location, geographic: true # 东西发布的位置
      t.string  :location_name              # 东西发布的位置逆向编码的建筑物名称
      t.boolean :visible, default: true     # 用于假删除

      t.timestamps
    end
    
    add_index :items, :tag_id
    add_index :items, :user_id
    add_index :items, :location, using: :gist
  end
end
