# == Schema Information
#
# Table name: datapool_websites
#
#  id              :bigint(8)        not null, primary key
#  content_id      :string(255)
#  title           :string(255)      not null
#  basic_src       :string(255)      not null
#  uuid            :string(255)      not null
#  remain_src      :text(65535)
#  crawl_state     :integer          default("single_standby"), not null
#  last_crawl_time :datetime
#  options         :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_basic_src   (basic_src)
#  index_datapool_websites_on_content_id  (content_id)
#  index_datapool_websites_on_uuid        (uuid) UNIQUE
#

require 'test_helper'

class Datapool::WebsiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
