# == Schema Information
#
# Table name: datapool_websites
#
#  id         :bigint(8)        not null, primary key
#  type       :string(255)
#  title      :string(255)      not null
#  basic_src  :string(255)      not null
#  remain_src :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_basic_src_and_type  (basic_src,type)
#

class Datapool::Website < ApplicationRecord
end
