# == Schema Information
#
# Table name: users
#
#  id                  :bigint(8)        not null, primary key
#  email               :string(255)      not null
#  password            :string(255)      not null
#  uid                 :string(255)      not null
#  state               :integer          default(0), not null
#  point               :integer          default(0), not null
#  subscription_end_at :datetime
#  last_logined_at     :datetime         not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email            (email)
#  index_users_on_last_logined_at  (last_logined_at)
#  index_users_on_uid              (uid) UNIQUE
#

class User < ApplicationRecord
end
