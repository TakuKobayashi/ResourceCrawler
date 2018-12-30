class CreateDatapoolResourceKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_keywords do |t|
      t.integer :datapool_keyword_id, null: false
      t.integer :datapool_resource_metum_id, null: false
    end
    add_index :datapool_resource_keywords, :datapool_keyword_id, name: "resource_relation_keyword_id_index"
    add_index :datapool_resource_keywords, :datapool_resource_metum_id, name: "resource_relation_resource_id_index"

  end
end
