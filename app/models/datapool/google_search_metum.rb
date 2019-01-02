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

class Datapool::GoogleSearchMetum < Datapool::ResourceMetum
  GOOGLE_SEARCH_URL = "https://www.google.co.jp/search"

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
    website_src_websites = {}
    website_src_images = {}
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
      image = self.constract(
        url: image_url.to_s,
        title: keyword.to_s,
        check_file: true,
        options: {
          keywords: keyword.to_s,
          number: number + counter + 1
        }.merge(options)
      )
      if image.blank?
        image = self.constract(
          url: searched_thumbnail_urls[index].to_s,
          title: keyword.to_s,
          check_file: true,
          options: {
            keyword: keyword.to_s,
            number: number + counter + 1
          }.merge(options)
        )
      end
      if image.present?
        web_attribute = web_attributes[index] || {}
        website = self.constract(
          url: link_metum["imgrefurl"].to_s,
          title: web_attribute["pt"].to_s,
          options: {
            keyword: keyword.to_s,
            number: number + counter + 1
          }
        )
        website_src_websites[link_metum["imgrefurl"].to_s] = website
        website_src_images[link_metum["imgrefurl"].to_s] = image
        counter = counter + 1
      end
    end
    Datapool::Website.import_resources!(resources: website_src_websites.values)
    websites = Datapool::Website.find_by_url(url: website_src_websites.keys)
    images = websites.map do |website|
      image = website_src_images[website.src]
      image.try(:datapool_website_id, website.id)
      image
    end.compact
    self.import_resources!(resources: images)
    return images
  end

  protected
  def self.url_partition(url:)
    aurl = Addressable::URI.parse(url)
    pure_url = URI.unescape(aurl.origin.to_s + aurl.path.to_s)
    if pure_url.size > 255
      word_counter = 0
      srces, other_pathes = pure_url.split("/").partition do |word|
        word_counter = word_counter + word.size + 1
        word_counter <= 255
      end
      basic_src = srces.join("/")
      remain_src = "/" + other_pathes.join("/")
    else
      basic_src = pure_url
      remain_src = ""
    end
    if aurl.query.present?
      remain_src += "?" + aurl.query
    end
    return basic_src, URI.unescape(remain_src)
  end
end
