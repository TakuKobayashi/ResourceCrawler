# == Schema Information
#
# Table name: datapool_resource_keywords
#
#  id                         :bigint(8)        not null, primary key
#  datapool_keyword_id        :integer          not null
#  datapool_resource_metum_id :integer          not null
#
# Indexes
#
#  resource_relation_keyword_id_index   (datapool_keyword_id)
#  resource_relation_resource_id_index  (datapool_resource_metum_id)
#

class Datapool::ResourceKeyword < ApplicationRecord
end
