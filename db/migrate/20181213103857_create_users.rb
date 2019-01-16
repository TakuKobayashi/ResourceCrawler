class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password, null: false
      t.string :uid, null: false
      t.integer :state, null: false, default: 0
      t.integer :point, null: false, default: 0
      t.datetime :subscription_end_at
      t.datetime :last_logined_at, null: false
      t.timestamps
    end
    add_index :users, :email
    add_index :users, :uid, unique: true
    add_index :users, :last_logined_at
  end
end
