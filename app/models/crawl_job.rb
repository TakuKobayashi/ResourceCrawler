# == Schema Information
#
# Table name: crawl_jobs
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :integer          not null
#  crawling_model_name   :string(255)      not null
#  uuid                  :string(255)      not null
#  state                 :integer          default("standby"), not null
#  priority              :bigint(8)        default(0), not null
#  current_crawled_count :integer          default(0), not null
#  cost                  :integer          default(0), not null
#  crawl_settings        :text(65535)      not null
#  options               :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_crawl_jobs_on_priority  (priority)
#  index_crawl_jobs_on_user_id   (user_id)
#  index_crawl_jobs_on_uuid      (uuid)
#

class CrawlJob < ApplicationRecord
  serialize :options, JSON

  enum state: {
    standby: 0,
    pending: 1,
    crawling: 2,
    downloading: 3,
    complete: 4,
    errored: 9,
  }

  belongs_to :user, class_name: 'User', foreign_key: :user_id, required: false
  has_many :job_resources, class_name: 'JobResource', foreign_key: :crawl_job_id
end
