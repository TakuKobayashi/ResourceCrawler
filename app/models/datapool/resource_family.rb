# == Schema Information
#
# Table name: datapool_resource_families
#
#  id                   :bigint(8)        not null, primary key
#  parent_resource_uuid :string(255)      not null
#  child_resource_uuid  :string(255)
#  child_resource_url   :string(255)      not null
#
# Indexes
#
#  datapool_resource_families_parent_uuid  (parent_resource_uuid)
#

class Datapool::ResourceFamily < ApplicationRecord
  belongs_to :parent, class_name: 'Datapool::ResourceMetum', primary_key: :uuid, foreign_key: :parent_resource_uuid, required: false
  belongs_to :child, class_name: 'Datapool::ResourceMetum', primary_key: :uuid, foreign_key: :child_resource_uuid, required: false
end
