# == Schema Information
#
# Table name: job_resources
#
#  id                 :bigint(8)        not null, primary key
#  crawl_job_id       :bigint(8)
#  resource_meta_uuid :string(255)      not null
#  state              :integer          default("standby"), not null
#  priority           :bigint(8)        default(0), not null
#  lock_version       :integer          default(0), not null
#
# Indexes
#
#  index_job_resources_on_crawl_job_id        (crawl_job_id)
#  index_job_resources_on_priority            (priority)
#  index_job_resources_on_resource_meta_uuid  (resource_meta_uuid)
#

require 'test_helper'

class JobResourceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
