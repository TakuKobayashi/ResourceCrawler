# == Schema Information
#
# Table name: accesses
#
#  id               :bigint(8)        not null, primary key
#  user_id          :bigint(8)
#  uid              :string(255)      not null
#  ip_address       :string(255)      not null
#  user_agent       :text(65535)
#  access_count     :integer          default(0), not null
#  last_accessed_at :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accesses_on_uid      (uid) UNIQUE
#  index_accesses_on_user_id  (user_id)
#

class Access < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: :user_id, required: false
end
