# == Schema Information
#
# Table name: datapool_websites
#
#  id          :bigint(8)        not null, primary key
#  title       :string(255)      not null
#  basic_src   :string(255)      not null
#  remain_src  :text(65535)
#  crawl_state :integer          default(0), not null
#  options     :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_basic_src  (basic_src)
#

class Datapool::Website < Datapool::ResourceBase
  serialize :options, JSON
end
