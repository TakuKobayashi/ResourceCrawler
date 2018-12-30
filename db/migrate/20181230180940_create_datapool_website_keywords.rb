class CreateDatapoolWebsiteKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_website_keywords do |t|
      t.integer :datapool_keyword_id, null: false
      t.integer :datapool_website_id, null: false
    end
    add_index :datapool_website_keywords, :datapool_keyword_id, name: "website_relation_keyword_id_index"
    add_index :datapool_website_keywords, :datapool_website_id, name: "website_relation_website_id_index"
  end
end
