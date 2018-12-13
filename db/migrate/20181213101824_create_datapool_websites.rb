class CreateDatapoolWebsites < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_websites do |t|
      t.string :type
      t.string :title, null: false
      t.string :basic_src, null: false
      t.text :remain_src
      t.text :options
    end
    add_index :datapool_websites, [:basic_src, :type]
  end
end
