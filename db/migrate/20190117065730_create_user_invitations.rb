class CreateUserInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :user_invitations do |t|
      t.integer :user_id, limit: 8, null: false
      t.integer :state, null: false, default: 0
      t.string :token, null: false
      t.string :invite_url, null: false
      t.string :qrcode_image_url
      t.timestamps
    end
    add_index :user_invitations, :user_id
    add_index :user_invitations, :token, unique: true
  end
end
