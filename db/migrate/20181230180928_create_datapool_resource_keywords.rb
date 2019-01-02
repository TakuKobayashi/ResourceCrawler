class CreateDatapoolResourceKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_keywords do |t|
      t.string :datapool_keyword_uuid, null: false
      t.string :datapool_resource_metum_uuid, null: false
    end
    add_index :datapool_resource_keywords, :datapool_keyword_uuid, name: "resource_relation_keyword_uuid_index"
    add_index :datapool_resource_keywords, :datapool_resource_metum_uuid, name: "resource_relation_resource_uuid_index"
  end
end
