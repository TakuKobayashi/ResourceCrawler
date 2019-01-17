class CreateJobResources < ActiveRecord::Migration[5.2]
  def change
    create_table :job_resources do |t|
      t.integer :crawl_job_id, null: false, limit: 8, default: 0
      t.string :resource_meta_uuid, null: false
      t.integer :state, null: false, default: 0
      t.integer :priority, null: false, limit: 8, default: 0
      t.integer :lock_version, null: false, default: 0
    end
    add_index :job_resources, :crawl_job_id
    add_index :job_resources, :resource_meta_uuid
    add_index :job_resources, :priority
  end
end
