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

class Datapool::WebsiteResourceMetum < Datapool::ResourceMetum
  def src=(url)
    aurl = Addressable::URI.parse(url.to_s)
    if self.image? && aurl.scheme == "data"
      image_binary =  Base64.decode64(aurl.to_s.gsub(/data:image\/.+;base64\,/, ""))
      image_type = aurl.to_s.gsub(/data:image\//, "").gsub(/;base64\,.+/, "")
      new_filename = SecureRandom.hex + ".#{image_type.to_s.downcase}"
      uploaded_path = ResourceUtility.upload_s3(image_binary, self.s3_root_path + new_filename)
      aurl = Addressable::URI.parse(Datapool::ResourceMetum::S3_ROOT_URL + uploaded_path)
    end
    basic_src, remain_src = WebNormalizer.url_partition(url: aurl.to_s)
    self.basic_src = basic_src
    self.remain_src = remain_src
  end
end
