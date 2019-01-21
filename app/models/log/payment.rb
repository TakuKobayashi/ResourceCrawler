# == Schema Information
#
# Table name: log_payments
#
#  id                  :bigint(8)        not null, primary key
#  type                :string(255)      not null
#  user_id             :bigint(8)        not null
#  price               :float(24)        default(0.0), not null
#  amount              :integer          default(0), not null
#  transaction_id      :string(255)      not null
#  payment_method_name :string(255)      not null
#  service_name        :string(255)      not null
#  paymented_at        :datetime         not null
#  payload             :text(65535)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_log_payments_on_transaction_id_and_type  (transaction_id,type)
#  index_log_payments_on_user_id_and_type         (user_id,type)
#

class Log::Payment < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: :user_id, required: false
end
