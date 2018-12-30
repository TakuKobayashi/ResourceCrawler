class CreateDatapoolWebsiteRelations < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_website_relations do |t|
      t.integer :parent_website_id, null: false
      t.integer :child_website_id, null: false
      t.string :host_url, null: false
    end
  end
end
