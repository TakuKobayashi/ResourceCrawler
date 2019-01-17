class CreateDatapoolWebsiteRelations < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_website_relations do |t|
      t.integer :parent_website_id, limit: 8, null: false
      t.integer :child_website_id, limit: 8, null: false
      t.string :host_url, null: false
    end
    add_index :datapool_website_relations, :parent_website_id
    add_index :datapool_website_relations, :child_website_id
    add_index :datapool_website_relations, :host_url
  end
end
