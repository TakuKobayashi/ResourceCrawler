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

class Datapool::GoogleSearchMetum < Datapool::ResourceMetum
  GOOGLE_SEARCH_URL = "https://www.google.co.jp/search"

  def src=(url)
    basic_src, remain_src = WebNormalizer.url_partition(url: url)
    self.basic_src = basic_src
    self.remain_src = remain_src
  end

  def self.search_images!(keyword:)
    all_images = []
    counter = 0
    loop do
      search_url = Addressable::URI.parse(GOOGLE_SEARCH_URL)
      #tbm=ischは画像検索の結果のタブ, ijnはどうやる100件ごとのページ番号のよう
      search_url.query_values = {q: keyword, tbm: "isch", start: counter, ijn: (counter / 100).to_i}
      start_time = Time.current
      images = self.import_search_images!(search_url: search_url.to_s, number: counter, keyword: keyword)
      break if images.blank?
      all_images += images
      counter = counter + images.size
      sleep_second = 1.second - (Time.current - start_time).second
      if sleep_second > 0
        sleep sleep_second
      end
    end
    return all_images
  end

  # 画像ファイルの拡張子の後ろに何かゴミがついていることがあるので、それは取り除く
  def self.laundering_url_path(url:)
    resource_url = Addressable::URI.parse(url.to_s)
    pathes = resource_url.path.split("/")
    if pathes.size > 0
      pathes[pathes.size - 1] = self.match_filename(resource_url.to_s)
    else
      pathes = [("/" + self.match_filename(resource_url.to_s))]
    end
    resource_url.path = pathes.join("/")
    return resource_url.to_s
  end

  def self.import_search_images!(search_url:, keyword:, number: 0, options: {})
    websites = []
    images = []
    img_dom = RequestParser.request_and_parse_html(url: search_url.to_s, options: {:follow_redirect => true})
    searched_urls = img_dom.css("a").map{|a| Addressable::URI.parse(a["href"].to_s) }
    web_attributes = img_dom.css(".rg_meta").map do |a|
      begin
        JSON.parse(a.text)
      rescue JSON::ParserError => e
        {}
      end
    end
    return [] if searched_urls.blank?
    searched_thumbnail_urls = img_dom.css("img").map do |img|
      if img["data-src"].blank?
        img["data-src"]
      else
        img["src"]
      end
    end
    counter = 0
    searched_urls.each_with_index do |url, index|
      link_metum = url.query_values
      next if link_metum["imgurl"].blank? && link_metum["imgrefurl"].blank?
      image_url = self.laundering_url_path(url: link_metum["imgurl"].to_s)
      split_keywords = keyword.to_s.split(" ")
      image = nil
      if !Datapool::ImageMetum.invlide_file?(url: image_url.to_s)
        image = self.constract(
          url: image_url.to_s,
          title: keyword.to_s,
          options: {
            number: number + counter + 1
          }.merge(options)
        )
      end
      if image.blank?
        searched_thumbnail_url = searched_thumbnail_urls[index].to_s
        if !Datapool::ImageMetum.invlide_file?(url: searched_thumbnail_url)
          image = self.constract(
            url: searched_thumbnail_url,
            title: keyword.to_s,
            options: {
              number: number + counter + 1
            }.merge(options)
          )
        end
      end
      if image.present?
        web_attribute = web_attributes[index] || {}
        website = self.constract(
          url: link_metum["imgrefurl"].to_s,
          title: web_attribute["pt"].to_s,
          options: {
            number: number + counter + 1
          }
        )
        image.datapool_website_uuid = website.uuid
        websites << website
        images << image
        counter = counter + 1
      end
    end
    Datapool::Website.import_resources!(resources: websites)
    self.import_resources!(resources: images)
    return images
  end
end
