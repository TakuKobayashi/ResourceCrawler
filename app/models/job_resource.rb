# == Schema Information
#
# Table name: job_resources
#
#  id                 :bigint(8)        not null, primary key
#  crawl_job_ids      :text(65535)      not null
#  resource_meta_uuid :string(255)      not null
#  state              :integer          default(0), not null
#  priority           :integer          default(0), not null
#
# Indexes
#
#  index_job_resources_on_priority            (priority)
#  index_job_resources_on_resource_meta_uuid  (resource_meta_uuid)
#

class JobResource < ApplicationRecord
end
