# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                  :bigint(8)        not null, primary key
#  type                :string(255)
#  datapool_website_id :integer
#  resource_genre      :integer          default("unknown"), not null
#  title               :string(255)      not null
#  original_filename   :text(65535)
#  basic_src           :string(255)      not null
#  remain_src          :text(65535)
#  file_size           :integer          default(0), not null
#  md5sum              :string(255)      default(""), not null
#  backup_url          :string(255)
#  options             :text(65535)
#
# Indexes
#
#  index_datapool_resource_meta_on_basic_src_and_type   (basic_src,type)
#  index_datapool_resource_meta_on_datapool_website_id  (datapool_website_id)
#  index_datapool_resource_meta_on_md5sum               (md5sum)
#

class Datapool::InstagramMetum < Datapool::ResourceMetum
  INSTAGRAM_TAG_SEARCH_API_URL = "https://www.instagram.com/explore/tags/"

  def self.search_resources!(keyword:)
    all_images = []
    counter = 0
    images = []
    doc = RequestParser.request_and_parse_html(url: INSTAGRAM_TAG_SEARCH_API_URL + URI.encode(keyword.to_s) + "/")
    target_json_strings = doc.css("script").map{|js_dom| Sanitizer.scan_brace(js_dom.text) }.flatten.uniq
    target_json_hashes = target_json_strings.map do |json_string|
      json_hash = {}
      begin
        json_hash = JSON.parse(json_string)
      rescue JSON::ParserError => e
        json_hash = {}
      end
      p json_hash
      json_hash
    end
    target_json_hashes.select!(&:present?)
    return target_json_hashes
 #   json_hash["entry_data"]["TagPage"].each do |hash|
 #     hash["graphql"]["hashtag"]
      #https://www.instagram.com/graphql/query/?query_hash=ded47faa9a1aaded10161a2ff32abb6b&variables=%7B%22tag_name%22%3A%22hashtag%22%2C%22first%22%3A6%2C%22after%22%3A%22AQBaFbFAFi8BjvNFCwHWZDiqA4SWwRTf9jVotEHCJPSKWiY8mgm-tg2VwyfWfQp1CUT1TFE3D5DTqUTluAEVwTIV67xppOzuI7OgTIB2TeuBCQ%22%7D
      #query
      #{
      #  query_hash: ded47faa9a1aaded10161a2ff32abb6b
      #  variables: {"tag_name":"hashtag","first":6,"after":"AQBaFbFAFi8BjvNFCwHWZDiqA4SWwRTf9jVotEHCJPSKWiY8mgm-tg2VwyfWfQp1CUT1TFE3D5DTqUTluAEVwTIV67xppOzuI7OgTIB2TeuBCQ"}
      #}
      #request header
      #{
      #  :authority: www.instagram.com
      #  :path: /graphql/query/?query_hash=ded47faa9a1aaded10161a2ff32abb6b&variables=%7B%22tag_name%22%3A%22hashtag%22%2C%22first%22%3A6%2C%22after%22%3A%22AQBaFbFAFi8BjvNFCwHWZDiqA4SWwRTf9jVotEHCJPSKWiY8mgm-tg2VwyfWfQp1CUT1TFE3D5DTqUTluAEVwTIV67xppOzuI7OgTIB2TeuBCQ%22%7D
      #  cookie: csrftoken=1hQXvpaBvOPFkRe5neqRpnlm4cD4M5HH; mid=WnF7-AAEAAHv78teJV4zW5h2gXQC; fbm_124024574287414=base_domain=.instagram.com; rur=FTW; fbsr_124024574287414=tBZYx7w6U8gIQg6Q4oa7Ym3MF-W5tS-7y7N5E2WB_no.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNvZGUiOiJBUUNMRWFOdjVHYjl2enc5blFYV0JfSHpPaW8ydUJSOFBJOXJzUUdGbEUxZHYySXRmUFAwVWo3RTNaVUU1X19MY0U3U0Fob0lMM2hLMUlXcTZya080bldkWUZaWDFsNFdlVVE0aUdSdjFWQW1kNERoSFkzc0xEZkNQVXU2eUFRWjNGWk83TWRaTHBQVWtJSndVY0VnOGtIalZ5RHpTTFFQTkpnTzljeVA3eEdNYnhib3pQUVBINC1YWlVLU3VZdjJWMWNhWDIzTTlSVi1UQXNMVEM0WDQzcHlXTktna3BaODN1LVlYQWVDT1ZqRU1LLURjSmdGaVl1Zk9nOWdWUVNkdFBycndOY2xMWnBjSk0tMnU2YU5PX3R2TDM0MnczWk92X09KUWNhZksxMlU3TXZfMTB3bXo0VG1qQnZ1NnJzZVR1TFVieDNleDRoWGNQcTRsN2Y0aUJvcCIsImlzc3VlZF9hdCI6MTUyNjYyNDYxOCwidXNlcl9pZCI6IjEwMDAwMTg5Mjc5OTM0MCJ9; urlgen="{\"time\": 1526624603\054 \"27.110.34.94\": 10021}:1fJYnr:LHcSlC2cJ-KGO_RQaRyH02wjIk8"
      #  referer: https://www.instagram.com/explore/tags/hashtag/
      #  user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Mobile Safari/537.36
      #  x-instagram-gis: a249f8ce6a8e16edd3d17b761bb1a4c5
      #  x-requested-with: XMLHttpRequest
      #}
   #end
  end
end
