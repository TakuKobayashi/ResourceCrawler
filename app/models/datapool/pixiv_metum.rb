# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                    :bigint(8)        not null, primary key
#  type                  :string(255)
#  datapool_website_uuid :string(255)
#  uuid                  :string(255)      not null
#  resource_genre        :integer          default("unknown"), not null
#  title                 :string(255)      not null
#  original_filename     :text(65535)
#  basic_src             :string(255)      not null
#  remain_src            :text(65535)
#  file_size             :integer          default(0), not null
#  md5sum                :string(255)      default(""), not null
#  backup_url            :string(255)
#  options               :text(65535)
#
# Indexes
#
#  index_datapool_resource_meta_on_basic_src_and_type     (basic_src,type)
#  index_datapool_resource_meta_on_datapool_website_uuid  (datapool_website_uuid)
#  index_datapool_resource_meta_on_md5sum                 (md5sum)
#  index_datapool_resource_meta_on_uuid                   (uuid) UNIQUE
#

class Datapool::PixivMetum < Datapool::ResourceMetum
end


