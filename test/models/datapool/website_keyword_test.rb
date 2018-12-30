# == Schema Information
#
# Table name: datapool_website_keywords
#
#  id                  :bigint(8)        not null, primary key
#  datapool_keyword_id :integer          not null
#  datapool_website_id :integer          not null
#
# Indexes
#
#  website_relation_keyword_id_index  (datapool_keyword_id)
#  website_relation_website_id_index  (datapool_website_id)
#

require 'test_helper'

class Datapool::WebsiteKeywordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
