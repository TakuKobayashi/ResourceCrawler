class CreateDatapoolResourceMeta < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_meta do |t|
      t.string :type
      t.integer :resource_genre, null: false, default: 0
      t.string :title, null: false
      t.string :original_filename
      t.string :basic_src, null: false
      t.text :remain_src
      t.text :options
    end

    add_index :datapool_resource_meta, [:basic_src, :type]
  end
end
