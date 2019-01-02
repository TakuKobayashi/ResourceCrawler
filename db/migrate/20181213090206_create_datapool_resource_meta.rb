class CreateDatapoolResourceMeta < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_meta do |t|
      t.string :type
      t.string :datapool_website_uuid
      t.string :uuid, null: false
      t.integer :resource_genre, null: false, default: 0
      t.string :title, null: false
      t.text :original_filename
      t.string :basic_src, null: false
      t.text :remain_src
      t.integer :file_size, null: false, default: 0
      t.string :md5sum, null: false, default: ""
      t.string :backup_url
      t.text :options
    end

    add_index :datapool_resource_meta, :datapool_website_uuid
    add_index :datapool_resource_meta, :uuid, unique: true
    add_index :datapool_resource_meta, :md5sum
    add_index :datapool_resource_meta, [:basic_src, :type]
  end
end
