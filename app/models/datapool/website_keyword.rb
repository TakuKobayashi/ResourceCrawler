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
end
