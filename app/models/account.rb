# == Schema Information
#
# Table name: accounts
#
#  id           :bigint(8)        not null, primary key
#  user_id      :integer          not null
#  type         :string(255)
#  uid          :string(255)      not null
#  token        :text(65535)
#  token_secret :text(65535)
#  expired_at   :datetime
#  options      :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_accounts_on_uid_and_type  (uid,type) UNIQUE
#  index_accounts_on_user_id       (user_id)
#

class Account < ApplicationRecord
end
