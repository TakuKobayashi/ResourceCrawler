# == Schema Information
#
# Table name: datapool_websites
#
#  id          :bigint(8)        not null, primary key
#  title       :string(255)      not null
#  basic_src   :string(255)      not null
#  remain_src  :text(65535)
#  crawl_state :integer          default(0), not null
#  options     :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_basic_src  (basic_src)
#

class Datapool::Website < Datapool::ResourceBase
  serialize :options, JSON

  def self.constract_from_tweet(tweet:, options: {})
    return [] unless tweet.urls?
    tweet_text = Sanitizer.delete_urls(tweet.text)

    websites = tweet.urls.flat_map do |urle|
      website = Datapool::Website.new
      website.src = urle.expanded_url.to_s
      website.title = tweet_text
      website.options = {
        tweet_id: tweet.id
      }.merge(options)
      website
    end
    return websites.flatten
  end
end
