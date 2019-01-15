class CreateCrawlJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :crawl_jobs do |t|
      t.string :user_type, null: false
      t.integer :user_id, null: false
      t.string :from_type, null: false
      t.text :from_ids, null: false
      t.string :uuid, null: false
      t.integer :state, null: false, default: 0
      t.integer :priority, null: false, default: 0
      t.integer :current_crawled_count, null: false, default: 0
      t.text :options
      t.timestamps
    end
    add_index :crawl_jobs, [:user_type, :user_id]
    add_index :crawl_jobs, :token
  end
end
