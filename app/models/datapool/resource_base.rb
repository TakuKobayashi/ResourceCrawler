class Datapool::ResourceBase < ApplicationRecord
  self.abstract_class = true

  def src
    return URI.escape(self.basic_src.to_s + self.remain_src.to_s)
  end

  def src=(url)
    basic_src, remain_src = self.url_partition(url: url)
    self.basic_src = basic_src
    self.remain_src = remain_src
  end

  def self.find_by_basic_src_from_url(url:)
    urls = [url].flatten.uniq
    basic_srces = []
    urls.each do |u|
      basic_src, remain_src = self.url_partition(url: u)
      basic_srces << basic_src
    end
    return self.where(basic_src: basic_srces)
  end

  def self.find_by_url(url:)
    urls = [url].flatten.uniq
    src_resources = self.find_by_basic_src_from_url(url: url).index_by(&:src)
    return urls.map{|url| src_resources[url.to_s] }
  end

  def self.import_resources!(resources:)
    src_resources = self.find_by_basic_src_from_url(url: resources.map(&:src).uniq).index_by(&:src)
    import_resources = resources.select{|imp| src_resources[imp.src].blank? }.uniq(&:src)
    if import_resources.present?
      self.import!(import_resources)
    end
  end

  protected
  def self.url_partition(url:)
    aurl = Addressable::URI.parse(url)
    pure_url = aurl.origin.to_s + aurl.path.to_s
    if aurl.query.present?
      pure_url += "?" + aurl.query
    end
    pure_url = URI.unescape(pure_url)
    if pure_url.size > 255
      urlpath = URI.unescape(aurl.origin.to_s + aurl.path.to_s)
      word_counter = 0
      srces, other_pathes = urlpath.split("/").partition do |word|
        word_counter = word_counter + word.size + 1
        word_counter <= 255
      end
      basic_src = srces.join("/")
      remain_src = ""
      if other_pathes.present?
        remain_src = "/" + other_pathes.join("/")
      end
      if aurl.query.present?
        remain_src += "?" + aurl.query
      end
    else
      basic_src = pure_url
      remain_src = ""
    end
    return basic_src, remain_src
  end
end