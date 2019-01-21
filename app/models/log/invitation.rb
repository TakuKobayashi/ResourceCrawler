# == Schema Information
#
# Table name: log_invitations
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  invited_user_id    :bigint(8)        not null
#  user_invitation_id :bigint(8)        not null
#  level              :integer          default(0), not null
#  registered_at      :datetime
#  access_from        :string(255)
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_log_invitations_on_invited_user_id     (invited_user_id)
#  index_log_invitations_on_user_id             (user_id)
#  index_log_invitations_on_user_invitation_id  (user_invitation_id)
#

class Log::Invitation < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: :user_id, required: false
  belongs_to :invited_user, class_name: 'User', foreign_key: :invited_user_id, required: false
  belongs_to :invitation, class_name: 'UserInvitation', foreign_key: :user_invitation_id, required: false
end
