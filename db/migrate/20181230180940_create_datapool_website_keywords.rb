class CreateDatapoolWebsiteKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_website_keywords do |t|
      t.string :datapool_keyword_uuid, null: false
      t.string :datapool_website_uuid, null: false
    end
    add_index :datapool_website_keywords, :datapool_keyword_uuid, name: "website_relation_keyword_uuid_index"
    add_index :datapool_website_keywords, :datapool_website_uuid, name: "website_relation_website_uuid_index"
  end
end
