# == Schema Information
#
# Table name: crawl_jobs
#
#  id                 :bigint(8)        not null, primary key
#  user_type          :string(255)      not null
#  user_id            :integer          not null
#  from_type          :string(255)      not null
#  from_ids           :text(65535)      not null
#  token              :string(255)      not null
#  state              :integer          not null
#  upload_url         :string(255)
#  recieved_file_size :integer          default(0), not null
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_crawl_jobs_on_token                  (token)
#  index_crawl_jobs_on_user_type_and_user_id  (user_type,user_id)
#

class CrawlJob < ApplicationRecord
end
