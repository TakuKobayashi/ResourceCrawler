# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                    :bigint(8)        not null, primary key
#  type                  :string(255)
#  content_id            :string(255)
#  datapool_website_uuid :string(255)
#  uuid                  :string(255)      not null
#  appear_state          :integer          default("appearing"), not null
#  resource_genre        :integer          default("unknown"), not null
#  title                 :string(255)      not null
#  original_filename     :text(65535)
#  basic_src             :string(255)      not null
#  remain_src            :text(65535)
#  thumbnail_url         :string(255)
#  asset_file_url        :string(255)
#  options               :text(65535)
#
# Indexes
#
#  index_datapool_resource_meta_on_basic_src_and_type  (basic_src,type)
#  index_datapool_resource_meta_on_content_id          (content_id)
#  index_datapool_resource_meta_on_uuid                (uuid) UNIQUE
#

class Datapool::NiconicoMetum < Datapool::ResourceMetum
  NICONICO_CONTENT_API_URL = "http://api.search.nicovideo.jp/api/v2/illust/contents/search"

  def self.crawl_images!(keyword:)
    all_images = []
    counter = 0
    loop do
      images = []
      json = RequestParser.request_and_parse_json(url: NICONICO_CONTENT_API_URL, params: {q: keyword, targets: "title,description,tags", _context: "taptappun", fields: "contentId,title,tags,categoryTags,thumbnailUrl", _sort: "-startTime", _offset: counter, _limit: 100})
      json["data"].each do |data_hash|
        image = self.constract(
          url: data_hash["thumbnailUrl"],
          title: data_hash["title"],
          options: {
            keywords: keyword.to_s,
            content_id: data_hash["contentId"],
            tags: data_hash["tags"].to_s.split(" "),
            category_tags: data_hash["categoryTags"].to_s.split(" ")
          }
        )
        images << image
      end
      break if images.blank?
      self.import_resources!(resources: images)
      all_images += images
      counter = counter + images.size
      break if json["meta"]["totalCount"].to_i <= counter
    end
    return all_images
  end

  NICONICO_VIDEO_HOSTS = [
    "nicovideo.jp"
  ]

  def self.suggest_genre(url)
    return :video
  end

  def download_resource(&block)
    if self.video?
      aurl = Addressable::URI.parse(self.src)
      response = RequestParser.request_and_response(url: aurl.to_s, options: {:follow_redirect => true})
      set_cookie_header = response.header["Set-Cookie"].detect{|cookie_str| cookie_str.include?("nicohistory=")}
      doc = Nokogiri::HTML.parse(response.body)
      info_json = doc.css("#js-initial-watch-data").first
      info_json_hash = JSON.parse(info_json["data-api-data"])
      video_url_hash = info_json_hash["video"]["smileInfo"]
      http_client = HTTPClient.new
      http_client.receive_timeout = 60 * 120
      http_client.get_content(video_url_hash["url"], header: {Cookie: set_cookie_header}) do |chunk|
        block.try(:call, chunk)
      end
      update!(
        content_id: info_json_hash["video"]["id"],
        thumbnail_url: info_json_hash["video"]["thumbnailURL"],
        options: {
          true_content_url: video_url_hash["url"]
        }
      )
    end
  end

  def self.niconico_video?(url)
    aurl = Addressable::URI.parse(url.to_s)
    return (NICONICO_VIDEO_HOSTS.any?{|host| host.include?(aurl.host)} && aurl.path.include?("/watch"))
  end
end
