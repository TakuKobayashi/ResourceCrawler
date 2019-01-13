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

class DatapoolResourceFamily < ApplicationRecord
end
