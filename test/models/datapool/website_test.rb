# == Schema Information
#
# Table name: datapool_websites
#
#  id              :bigint(8)        not null, primary key
#  title           :string(255)      not null
#  basic_src       :string(255)      not null
#  remain_src      :text(65535)
#  crawl_state     :integer          default("plane"), not null
#  last_crawl_time :datetime
#  options         :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_basic_src  (basic_src)
#

require 'test_helper'

class Datapool::WebsiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
