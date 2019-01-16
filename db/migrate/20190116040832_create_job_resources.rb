class CreateJobResources < ActiveRecord::Migration[5.2]
  def change
    create_table :job_resources do |t|
      t.text :crawl_job_ids, null: false
      t.string :resource_meta_uuid, null: false
      t.integer :state, null: false, default: 0
      t.integer :priority, null: false, default: 0
    end
    add_index :job_resources, :resource_meta_uuid
    add_index :job_resources, :priority
  end
end
