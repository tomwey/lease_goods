class AddTsvTitleToItems < ActiveRecord::Migration
  def change
    add_column :items, :tsv_title, :tsvector
    
    # 为新列添加索引
    execute <<-SQL
      CREATE INDEX index_items_tsv_title ON items USING gin(tsv_title);
    SQL
    
    # 同步已有数据到新的列
    execute <<-SQL
      UPDATE items SET tsv_title = (to_tsvector('lease_goods_zhcfg', coalesce(title, '')));
    SQL
    
    # # 当插入或更新title列时，设置一个触发器更新新列的值
    # execute <<-SQL
    # CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
    # ON items FOR EACH ROW EXECUTE PROCEDURE
    # tsvector_update_trigger(tsv_title, 'testzhcfg', title);
    # SQL
  end
end
