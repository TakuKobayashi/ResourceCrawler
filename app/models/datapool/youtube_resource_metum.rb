# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                    :bigint(8)        not null, primary key
#  type                  :string(255)
#  content_id            :string(255)
#  datapool_website_uuid :string(255)
#  uuid                  :string(255)      not null
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

class Datapool::YoutubeResourceMetum < Datapool::ResourceMetum
  YOUTUBE_HOSTS = [
    "www.youtube.com",
    "youtu.be"
  ]

  def src=(url)
    aurl = Addressable::URI.parse(url)
    query_hash = aurl.query_values
    self.basic_src = aurl.origin.to_s + aurl.path.to_s + "?v=" + query_hash["v"].to_s
    query_hash.delete_if{|key, value| key == "v" }
    if query_hash.present?
      self.remain_src = "&" + query_hash.map{|key, value| key.to_s + "=" + value.to_s }.join("&")
    else
      self.remain_src = ""
    end
  end

  def self.suggest_genre(url)
    return :video
  end

  def download_resource
    aurl = Addressable::URI.parse(self.src)
    file_name = self.filename + ".mp4"
    output_file_path = Rails.root.to_s + "/tmp/video/" + file_name
    system("youtube-dl " + self.src + " -o " + output_file_path.to_s)
    file = File.open(output_file_path)
    blob = file.read
    File.delete(output_file_path)
    return blob
  end

  def self.youtube?(url)
    aurl = Addressable::URI.parse(url.to_s)
    return (YOUTUBE_HOSTS.any?{|host| host.include?(aurl.host)} && aurl.path.include?("/watch"))
  end
end


