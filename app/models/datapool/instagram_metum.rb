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

class Datapool::InstagramMetum < Datapool::ResourceMetum
  INSTAGRAM_TAG_SEARCH_API_URL = "https://www.instagram.com/explore/tags/"

  def src=(url)
    aurl = Addressable::URI.parse(url)
    self.basic_src = aurl.origin.to_s + aurl.path.to_s
    if aurl.query.present?
      self.remain_src = "?" + aurl.query.to_s
    else
      self.remain_src = ""
    end
  end

  def self.search_inithialize_page_json_hashes(keyword:)
    doc = RequestParser.request_and_parse_html(url: INSTAGRAM_TAG_SEARCH_API_URL + URI.encode(keyword.to_s) + "/")
    target_json_strings = doc.css("script").map{|js_dom| Sanitizer.scan_brace(js_dom.text) }.flatten.uniq
    target_json_hashes = target_json_strings.map do |json_string|
      json_hash = {}
      begin
        json_hash = JSON.parse(json_string)
      rescue JSON::ParserError => e
        json_hash = {}
      end
      json_hash
    end
    return target_json_hashes.select(&:present?)
  end

  def self.suggest_genre(url)
    return :image
  end

  def self.search_and_import_resources!(keyword:)
    all_images = []
    counter = 0
    images = []
    target_json_hashes = self.search_inithialize_page_json_hashes(keyword: keyword)
    hashtags = self.mine_main_data(target_json_hashes)
    page_info = hashtags["edge_hashtag_to_media"]["page_info"]
    page_info["end_cursor"]
    page_info["has_next_page"]
    resources = self.import_from_json_hashtags!(hashtags["edge_hashtag_to_media"])
    resources += self.import_from_json_hashtags!(hashtags["edge_hashtag_to_top_posts"])
    resources += self.import_from_json_hashtags!(hashtags["edge_hashtag_to_content_advisory"])
    return resources
  end

  def self.import_from_json_hashtags!(hashtags)
    edges = hashtags["edges"]
    resources = edges.map do |edge|
      node = edge["node"] || {}
      caption = node["edge_media_to_caption"]["edges"].map{|e| e["node"]["text"] }.join
      title_body = caption.split(/[ |\n]#/).first.to_s.truncate(255)
      resource = self.constract(
        url: node["display_url"] || node["thumbnail_src"],
        title: title_body,
        options: {
          content_id: node["id"],
          post_user_id: node["owner"]["id"],
          post_at: Time.at(node["taken_at_timestamp"].to_i)
        }
      )
      if node["is_video"]
        resource.resource_genre = :video
      end
      resource
    end
    self.import_resources!(resources: resources)
    return resources
  end

  private
  def self.mine_main_data(target_json_hashes)
    hashkeys = ["entry_data","TagPage", "graphql", "hashtag"]
    hashes = target_json_hashes.map do |hash|
      hashtags = hashkeys.inject(hash) do |result, key|
        if result[key].instance_of?(Array)
          result = result[key].first || {}
        else
          result = result[key] || {}
        end
        result
      end
    end
    return hashes.detect(&:present?)
  end
end
