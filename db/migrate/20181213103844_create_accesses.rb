class CreateAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :accesses do |t|
      t.integer :user_id, limit: 8
      t.string :uid, null: false
      t.string :ip_address, null: false
      t.text :user_agent
      t.integer :access_count, null: false, default: 0
      t.datetime :last_accessed_at, null: false
      t.timestamps
    end
    add_index :accesses, :user_id
    add_index :accesses, :uid, unique: true
  end
end
