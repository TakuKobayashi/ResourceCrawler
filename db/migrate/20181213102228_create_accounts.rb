class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :user_id, limit: 8 ,null: false
      t.string :type
      t.string :uid, null: false
      t.text :token
      t.text :token_secret
      t.datetime :expired_at
      t.text :options
      t.timestamps
    end
    add_index :accounts, :user_id
    add_index :accounts, [:uid, :type], unique: true
  end
end
