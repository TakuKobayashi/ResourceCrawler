# == Schema Information
#
# Table name: datapool_resource_keywords
#
#  id                           :bigint(8)        not null, primary key
#  datapool_keyword_uuid        :string(255)      not null
#  datapool_resource_metum_uuid :string(255)      not null
#
# Indexes
#
#  resource_relation_keyword_uuid_index   (datapool_keyword_uuid)
#  resource_relation_resource_uuid_index  (datapool_resource_metum_uuid)
#

class Datapool::ResourceKeyword < ApplicationRecord
  belongs_to :keyword, class_name: 'Datapool::Keyword', foreign_key: :datapool_keyword_uuid, primary_key: :uuid, required: false
  belongs_to :resource, class_name: 'Datapool::ResourceMetum', foreign_key: :datapool_resource_metum_uuid, primary_key: :uuid, required: false
end
