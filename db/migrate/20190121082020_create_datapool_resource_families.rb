class CreateDatapoolResourceFamilies < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_families do |t|
      t.string :parent_resource_uuid, null: false
      t.string :child_resource_uuid
      t.string :child_resource_url, null: false
    end

    add_index :datapool_resource_families, :parent_resource_uuid, name: "datapool_resource_families_parent_uuid"
  end
end
