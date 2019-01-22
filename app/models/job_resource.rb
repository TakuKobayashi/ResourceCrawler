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

class JobResource < ApplicationRecord
  enum state: {
    standby: 0,
    downloading: 1,
    delivering: 2,
    delivered: 3,
    completed: 4,
    errored: 9,
  }

  belongs_to :crawl_job, class_name: 'CrawlJob', foreign_key: :crawl_job_id, required: false
  belongs_to :resource, class_name: 'Datapool::ResourceMetum', primary_key: :uuid, foreign_key: :resource_meta_uuid, required: false

  BATCH_SIZE = 1000

  def self.download_and_uploadfiles!
    priority = 2 ** (8 * 7)
    loop do
      job_resources = JobResource.
                      preload(:resource).
                      standby.
                      where("priority < ?", priority).
                      order("priority DESC").
                      limit(BATCH_SIZE)

      JobResource.standby.where(resource_meta_uuid: job_resources.map(&:resource_meta_uuid)).update_all(state: :downloading)
      job_resources.each do |job_resource|
        Tempfile.create(SecureRandom.hex(32)) do |tempfile|
          job_resource.resource.download_resource do |chunk|
            tempfile.write(chunk)
          end
          checksum = Digest::MD5.hexdigest(tempfile)
          filepath = job_resource.resource.s3_root_path + job_resource.resource.filename
          result = s3.put_object(bucket: "taptappun", body: tempfile, key: filepath)
          Datapool::ResourceExtend.create!(
            datapool_resource_meta_id: job_resource.resource.id,
            file_size: 0,
            md5sum: checksum,
            backup_url: Datapool::ResourceMetum::S3_ROOT_URL + filepath
          )
        end
      end
      JobResource.standby.where(resource_meta_uuid: job_resources.map(&:resource_meta_uuid)).update_all(state: :completed)
      break if job_resources.size < BATCH_SIZE
      priority = job_resources.last.priority
    end
  end
end
