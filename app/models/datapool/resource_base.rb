class Datapool::ResourceBase < ApplicationRecord
  self.abstract_class = true

  def src
    return self.basic_src + self.remain_src.to_s
  end

  def src=(url)
    basic_src, remain_src = Datapool::ResourceBase.url_partition(url: url)
    self.basic_src = basic_src
    self.remain_src = remain_src
  end

  def self.find_basic_src_by_url(url:)
    urls = [url].flatten.uniq
    basic_srces = []
    urls.each do |u|
      basic_src, remain_src = Datapool::ResourceBase.url_partition(url: u)
      basic_srces << basic_src
    end
    return self.where(basic_src: basic_srces)
  end

  private
  def self.url_partition(url:)
    aurl = Addressable::URI.parse(url)
    pure_url = aurl.origin.to_s + aurl.path.to_s
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
    return basic_src, other_src
  end
end