class CreateLogInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :log_invitations do |t|
      t.integer :user_id, limit: 8, null: false
      t.integer :invited_user_id, limit: 8, null: false
      t.integer :user_invitation_id, limit: 8, null: false
      t.integer :level, null: false, default: 0
      t.datetime :registered_at
      t.string :access_from
      t.text :options
      t.timestamps
    end
    add_index :log_invitations, :user_id
    add_index :log_invitations, :invited_user_id
    add_index :log_invitations, :user_invitation_id
  end
end
