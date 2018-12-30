# == Schema Information
#
# Table name: datapool_websites
#
#  id              :bigint(8)        not null, primary key
#  title           :string(255)      not null
#  basic_src       :string(255)      not null
#  remain_src      :text(65535)
#  crawl_state     :integer          default("plane"), not null
#  last_crawl_time :datetime
#  options         :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_basic_src  (basic_src)
#

class Datapool::Website < Datapool::ResourceBase
  serialize :options, JSON
  has_many :resources, class_name: 'Datapool::ResourceMetum', foreign_key: :datapool_website_id

  enum crawl_state: {
    plane: 0,
    will_recrawl: 1,
    crawled: 2
  }

  def self.constract_from_tweet(tweet:, options: {})
    return [] unless tweet.urls?
    tweet_text = Sanitizer.delete_urls(tweet.text)

    websites = tweet.urls.flat_map do |urle|
      website = self.constract(
        url: urle.expanded_url.to_s,
        title: tweet_text,
        options: {
          tweet_id: tweet.id
        }.merge(options)
      )
      website
    end
    return websites.flatten
  end

  def self.constract(url:, title:, options: {})
    website = Datapool::Website.new
    website.src = url.to_s
    website.title = title
    website.options = options
    return website
  end

  def scraping_html_recourses!
    html_dom = RequestParser.request_and_parse_html(url: self.src.to_s, options: {:follow_redirect => true})
    #docs = HTMLDom.doc_nodes(html_dom.children)
    #attr_values = docs.map{|d| d.attributes.values }.flatten

    css_js_extes = Datapool::WebMetum::CSS_FILE_EXTENSIONS + Datapool::WebMetum::JS_FILE_EXTENSIONS
    css_js_file_urls = Sanitizer.scan_url_path_resources(html_dom.to_html.downcase, css_js_extes)
    contents = Sanitizer.scan_url_path_resources(html_dom.to_html.downcase, Datapool::ResourceMetum.resource_file_extensions)
    css_js_file_urls.each do |url|
      text = RequestParser.request_and_response_body(url: self.src.to_s, options: {:follow_redirect => true})
      contents += Sanitizer.scan_url_path_resources(text.downcase, Datapool::ResourceMetum.resource_file_extensions)
    end
    resource_meta = contents.uniq.map do |url|
      Datapool::WebsiteResourceMetum.constract(
        url: url,
        title: self.title,
        website_id: self.id,
        check_file: true,
        options: {}
      )
    end
    self.transaction do
      Datapool::WebsiteResourceMetum.import_resources!(resources: resource_meta)
      self.update!(last_crawl_time: Time.current, crawl_state: :crawled)
    end
  end
end
