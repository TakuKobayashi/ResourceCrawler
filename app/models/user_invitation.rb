# == Schema Information
#
# Table name: user_invitations
#
#  id               :bigint(8)        not null, primary key
#  user_id          :bigint(8)        not null
#  state            :integer          default("activate"), not null
#  token            :string(255)      not null
#  invite_url       :string(255)      not null
#  qrcode_image_url :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_user_invitations_on_token    (token) UNIQUE
#  index_user_invitations_on_user_id  (user_id)
#

class UserInvitation < ApplicationRecord
  enum state: {
    activate: 0,
    banned: 1,
    expired: 2,
  }

  belongs_to :user, class_name: 'User', foreign_key: :user_id, required: false
  has_many :log_invitations, class_name: 'Log::Invitation', foreign_key: :user_invitation_id
end
