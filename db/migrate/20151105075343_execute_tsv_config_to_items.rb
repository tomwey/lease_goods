class ExecuteTsvConfigToItems < ActiveRecord::Migration
  def change
    # 创建Text Search Configuration
    execute <<-SQL
    DROP TEXT SEARCH CONFIGURATION IF EXISTS testzhcfg;
    CREATE TEXT SEARCH CONFIGURATION lease_goods_zhcfg (PARSER = zhparser);
    ALTER TEXT SEARCH CONFIGURATION lease_goods_zhcfg ADD MAPPING FOR n,v,a,i,e,l WITH simple;
    SQL
    
    # 当插入或更新title列时，设置一个触发器更新新列的值
    execute <<-SQL
    DROP TRIGGER IF EXISTS tsvectorupdate ON items;
    CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
    ON items FOR EACH ROW EXECUTE PROCEDURE
    tsvector_update_trigger(tsv_title, 'public.lease_goods_zhcfg', title);
    SQL
  end
end
