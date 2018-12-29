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

class Datapool::TwitterResourceMetum < Datapool::ResourceMetum
  TIMELINE_CRAWL_COUNT = 200

  def self.get_rest_client
    rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch('TWITTER_CONSUMER_KEY', '')
      config.consumer_secret     = ENV.fetch('TWITTER_CONSUMER_SECRET', '')
      config.access_token        = ENV.fetch('TWITTER_ACCESS_TOKEN', '')
      config.access_token_secret = ENV.fetch('TWITTER_ACCESS_TOKEN_SECRET', '')
    end
    return rest_client
  end

  def self.search_and_generate!(keyword:)
    twitter_client = self.get_rest_client
    tweets = []
    retry_count = 0
    options = {count: 100}
    begin
      tweets = twitter_client.search(keyword, options)
    rescue Twitter::Error::TooManyRequests => e
      Rails.logger.warn "twitter retry since:#{e.rate_limit.reset_in.to_i}"
      retry_count = retry_count + 1
      sleep e.rate_limit.reset_in.to_i
      if retry_count < 5
        retry
      else
        return []
      end
    end
    resources = self.generate_resources(tweets: tweets, options: {keyword: keyword})
    return resources
  end

  def self.user_timeline_and_generate!(username:)
    tweet_options = {count: TIMELINE_CRAWL_COUNT}
    twitter_client = self.get_rest_client
    resources = []
    last_tweet_id = nil

    loop do
      if last_tweet_id.present?
        tweet_options[:max_id] = last_tweet_id.to_i
      end
      retry_count = 0
      tweets = []
      begin
        tweets = twitter_client.user_timeline(username, tweet_options)
      rescue Twitter::Error::NotFound => e
        Rails.logger.warn "user not found:" + e.message
      rescue Twitter::Error::NotFound => e
        Rails.logger.warn "twitter retry since:#{e.rate_limit.reset_in.to_i}"
        retry_count = retry_count + 1
        sleep e.rate_limit.reset_in.to_i
        if retry_count < 5
          retry
        end
      end
      resources += self.generate_resources(tweets: tweets, options: {username: username})
      break if tweets.size < TIMELINE_CRAWL_COUNT
      last_tweet_id = tweets.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
    end
    return resources
  end

  private
  def self.generate_resources(tweets:, options: {})
    resources = []
    websites = []

    tweets.each do |tweet|
      resources += self.constract_from_tweet(tweet: tweet, options: options)
      websites += Datapool::Website.constract_from_tweet(tweet: tweet, options: options)

      if tweet.quoted_tweet?
        resources += self.constract_from_tweet(tweet: tweet.quoted_tweet, options: options)
        websites += Datapool::Website.constract_from_tweet(tweet: tweet.quoted_tweet, options: options)
      end
    end
    resources.uniq!(&:src)
    websites.uniq!(&:src)
    self.import_resources!(resources: resources)
    Datapool::Website.import_resources!(resources: websites)
    return resources
  end

  def self.constract_from_tweet(tweet:, options: {})
    return [] unless tweet.media?
    tweet_text = Sanitizer.basic_sanitize(tweet.text)
    tweet_text = Sanitizer.delete_urls(tweet_text)

    resources = tweet.media.flat_map do |m|
      case m
      when Twitter::Media::Photo
        image_resource = self.constract(
          url:, m.media_url.to_s,
          title: tweet_text,
          options: {
            tweet_id: tweet.id
          }.merge(options)
        )
        image_resource.resource_genre = :image]
        [image_resource]
      when Twitter::Media::Video
        variantes = m.video_info.try(:variants) || []
        max_bitrate_variant = variantes.max_by{|variant| variant.try(:bitrate).to_i }
        image_resource = self.constract(
          url: m.media_url.to_s,
          title: tweet_text,
          options: {
            tweet_id: tweet.id
          }.merge(options)
        )
        image_resource.resource_genre = :image
        video_resource = self.constract(
          url: max_bitrate_variant.try(:url).to_s,
          title: tweet_text,
          options: {
            tweet_id: tweet.id,
            duration: m.video_info.duration_millis
          }.merge(options)
        )
        video_resource.resource_genre = :video
        [image_resource, video_resource]
      else
        []
      end
    end
    return resources.flatten
  end
end
