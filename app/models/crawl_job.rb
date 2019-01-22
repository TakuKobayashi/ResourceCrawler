# == Schema Information
#
# Table name: crawl_jobs
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :integer          not null
#  keyword               :string(255)      not null
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
  # {
  #   crawl_types: [],
  #   crawl_resource_genres: []
  # }
  serialize :crawl_settings, JSON
  serialize :options, JSON

  enum state: {
    standby: 0,
    pending: 1,
    crawling: 2,
    crawled: 3,
    downloading: 4,
    complete: 5,
    errored: 9,
  }

  belongs_to :user, class_name: 'User', foreign_key: :user_id, required: false
  has_many :job_resources, class_name: 'JobResource', foreign_key: :crawl_job_id

  def start_crawl!
    self.crawling!
    crawl_types = self.crawl_settings[:crawl_types] || []
    resources = Datapool::GoogleSearchMetum.search_images!(keyword: self.keyword)
    resources += Datapool::InstagramMetum.search_and_import_resources!(keyword: self.keyword)
    resources += Datapool::FrickrMetum.search_resources!(search: {text: self.keyword})
    resources += Datapool::FrickrMetum.search_resources!(search: {tags: self.keyword})
    resources += Datapool::TwitterResourceMetum.search_and_generate!(keyword: self.keyword)
    new_job_resources = []
    # 古いものから順にpriorityをあげる
    base_priority = (Time.current - self.created_at).round
    resources.each do |resource|
      # 重いファイルはpriority低め
      rate = if resource.video?
               1
             elsif resource.audio?
               2
             elsif resource.threed_model?
               2
             elsif resource.compressed?
               1
             else
               3
             end
      job_resource = self.job_resources.new(
        resource_meta_uuid: resource.uuid,
        priority: base_priority * rate
      )
      new_job_resources << job_resource
    end
    JobResource.import!(new_job_resources)
    self.crawled!
  end
end
