# == Schema Information
#
# Table name: datapool_keywords
#
#  id         :bigint(8)        not null, primary key
#  keyword    :string(255)      not null
#  uuid       :string(255)      not null
#  used_count :integer          default(0), not null
#  options    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_datapool_keywords_on_keyword  (keyword) UNIQUE
#  index_datapool_keywords_on_uuid     (uuid) UNIQUE
#

require 'test_helper'

class Datapool::KeywordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
