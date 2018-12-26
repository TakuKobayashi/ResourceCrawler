# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                  :bigint(8)        not null, primary key
#  type                :string(255)
#  datapool_website_id :integer
#  resource_genre      :integer          default("image"), not null
#  title               :string(255)      not null
#  original_filename   :string(255)
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

  def download_resource
    super.download_resource
#    aurl = Addressable::URI.parse(self.src)
#    doc = RequestParser.request_and_parse_html(url: aurl.to_s, header: {"User-Agent" => "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Mobile Safari/537.36"}, options: {:follow_redirect => true})
#    doc.css("#jsDataContainer")
#    file_name = self.original_filename + ".mp4"
#    output_file_path = Rails.root.to_s + "/tmp/video/" + file_name
#    system("youtube-dl " + self.src + " -o " + output_file_path.to_s)
#    file = File.open(output_file_path)
#    blob = file.read
#    File.delete(output_file_path)
#    return blob
  end

  def self.niconico_video?(url)
    aurl = Addressable::URI.parse(url.to_s)
    return (NICONICO_VIDEO_HOSTS.any?{|host| host.include?(aurl.host)} && aurl.path.include?("/watch"))
  end
end
