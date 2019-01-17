class CreateDatapoolResourceExtends < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_extends do |t|
      t.integer :datapool_resource_meta_id, limit: 8, null: false
      t.integer :file_size, null: false, default: 0
      t.string :md5sum, null: false
      t.string :backup_url, null: false
    end
    add_index :datapool_resource_extends, :datapool_resource_meta_id, name: "datapool_resource_extends_resource_meta_id"
    add_index :datapool_resource_extends, :md5sum
  end
end
