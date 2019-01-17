# == Schema Information
#
# Table name: log_invitations
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)        not null
#  invited_user_id :bigint(8)        not null
#  level           :integer          not null
#  registered_at   :datetime
#  access_from     :string(255)
#  options         :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_log_invitations_on_invited_user_id  (invited_user_id)
#  index_log_invitations_on_user_id          (user_id)
#

class Log::Invitation < ApplicationRecord
end
