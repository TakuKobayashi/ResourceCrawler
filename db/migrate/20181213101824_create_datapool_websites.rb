class CreateDatapoolWebsites < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_websites do |t|
      t.string :content_id
      t.string :title, null: false
      t.string :basic_src, null: false
      t.string :uuid, null: false
      t.text :remain_src
      t.integer :crawl_state, null: false, default: 0
      t.datetime :last_crawl_time
      t.text :options
    end
    add_index :datapool_websites, :basic_src
    add_index :datapool_websites, :uuid, unique: true
    add_index :datapool_websites, :content_id
  end
end
