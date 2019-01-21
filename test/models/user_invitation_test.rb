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

require 'test_helper'

class UserInvitationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
