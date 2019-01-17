class CreateLogPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :log_payments do |t|
      t.string :type, null: false
      t.integer :user_id, limit: 8, null: false
      t.float :price, null: false, default: 0
      t.integer :amount, null: false, default: 0
      t.string :transaction_id, null: false
      t.string :payment_method_name, null: false
      t.string :service_name, null: false
      t.datetime :paymented_at, null: false
      t.text :payload, null: false
      t.timestamps
    end
    add_index :log_payments, [:user_id, :type]
    add_index :log_payments, [:transaction_id, :type]
  end
end
