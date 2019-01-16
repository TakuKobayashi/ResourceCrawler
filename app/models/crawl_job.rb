# == Schema Information
#
# Table name: crawl_jobs
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :integer          not null
#  crawling_model_name   :string(255)      not null
#  uuid                  :string(255)      not null
#  state                 :integer          default(0), not null
#  priority              :integer          default(0), not null
#  current_crawled_count :integer          default(0), not null
#  options               :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_crawl_jobs_on_user_id  (user_id)
#  index_crawl_jobs_on_uuid     (uuid)
#

class CrawlJob < ApplicationRecord
end
