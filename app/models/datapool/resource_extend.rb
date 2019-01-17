# == Schema Information
#
# Table name: datapool_resource_extends
#
#  id                        :bigint(8)        not null, primary key
#  datapool_resource_meta_id :bigint(8)        not null
#  file_size                 :integer          default(0), not null
#  md5sum                    :string(255)      not null
#  backup_url                :string(255)      not null
#
# Indexes
#
#  datapool_resource_extends_resource_meta_id  (datapool_resource_meta_id)
#  index_datapool_resource_extends_on_md5sum   (md5sum)
#

class Datapool::ResourceExtend < ApplicationRecord
end
