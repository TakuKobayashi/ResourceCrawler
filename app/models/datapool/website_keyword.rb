# == Schema Information
#
# Table name: datapool_website_keywords
#
#  id                    :bigint(8)        not null, primary key
#  datapool_keyword_uuid :string(255)      not null
#  datapool_website_uuid :string(255)      not null
#
# Indexes
#
#  website_relation_keyword_uuid_index  (datapool_keyword_uuid)
#  website_relation_website_uuid_index  (datapool_website_uuid)
#

class Datapool::WebsiteKeyword < ApplicationRecord
  belongs_to :keyword, class_name: 'Datapool::Keyword', foreign_key: :datapool_keyword_uuid, primary_key: :uuid, required: false
  belongs_to :website, class_name: 'Datapool::Website', foreign_key: :datapool_website_uuid, primary_key: :uuid, required: false
end
