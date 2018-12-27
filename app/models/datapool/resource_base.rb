class Datapool::ResourceBase < ApplicationRecord
  self.abstract_class = true

  def src
    return URI.escape(self.basic_src.to_s + self.remain_src.to_s)
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

  def self.import_resources!(resources:)
    src_resources = self.find_origin_src_by_url(url: resources.map(&:src).uniq).index_by(&:src)
    import_resources = resources.select{|imp| src_resources[imp.src].blank? }.uniq(&:src)
    if import_resources.present?
      self.import!(import_resources)
    end
  end

  private
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