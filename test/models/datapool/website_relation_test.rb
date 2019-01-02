# == Schema Information
#
# Table name: datapool_website_relations
#
#  id                :bigint(8)        not null, primary key
#  parent_website_id :integer          not null
#  child_website_id  :integer          not null
#  host_url          :string(255)      not null
#
# Indexes
#
#  index_datapool_website_relations_on_child_website_id   (child_website_id)
#  index_datapool_website_relations_on_host_url           (host_url)
#  index_datapool_website_relations_on_parent_website_id  (parent_website_id)
#

require 'test_helper'

class Datapool::WebsiteRelationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
