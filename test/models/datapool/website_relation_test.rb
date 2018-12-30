# == Schema Information
#
# Table name: datapool_website_relations
#
#  id                :bigint(8)        not null, primary key
#  parent_website_id :integer          not null
#  child_website_id  :integer          not null
#  host_url          :string(255)      not null
#

require 'test_helper'

class Datapool::WebsiteRelationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
