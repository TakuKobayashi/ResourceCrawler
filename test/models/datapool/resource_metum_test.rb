# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                :bigint(8)        not null, primary key
#  type              :string(255)
#  resource_genre    :integer          default(0), not null
#  title             :string(255)      not null
#  original_filename :string(255)
#  basic_src         :string(255)      not null
#  remain_src        :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_resource_meta_on_basic_src_and_type  (basic_src,type)
#

require 'test_helper'

class Datapool::ResourceMetumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
