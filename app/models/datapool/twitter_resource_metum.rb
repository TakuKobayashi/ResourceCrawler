# == Schema Information
#
# Table name: datapool_resource_meta
#
#  id                  :bigint(8)        not null, primary key
#  type                :string(255)
#  datapool_website_id :integer
#  resource_genre      :integer          default("image"), not null
#  title               :string(255)      not null
#  original_filename   :string(255)
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

  def self.search_image_tweet!(keyword:)
    twitter_client = TwitterRecord.get_twitter_rest_client("citore")
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
    return generate_images(tweets: tweets, options: {keyword: keyword})
  end

  def self.images_from_user_timeline!(username:)
    tweet_options = {count: TIMELINE_CRAWL_COUNT}
    twitter_client = TwitterRecord.get_twitter_rest_client("citore")
    images = []
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
      images += generate_images(tweets: tweets, options: {username: username})
      break if tweets.size < TIMELINE_CRAWL_COUNT
      last_tweet_id = tweets.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
    end
    return images
  end

  private
  def self.generate_images(tweets:, options: {})
    images = []
    videos = []
    websites = []
    quoteds_tweets = []

    tweets.each do |tweet|
      image_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet)
      image_urls.each do |image_url|
        images << self.constract_image_from_tweet(tweet: tweet, image_url: image_url, options: options)
      end

      videos += Datapool::TwitterVideoMetum.constract_from_tweet(tweet: tweet)
      websites += Datapool::TwitterWebsite.constract_from_tweet(tweet: tweet)
      if tweet.quoted_tweet?
        quoteds_tweets << tweet.quoted_tweet
      end
    end
    images.uniq!(&:src)
    self.import_resources!(resources: images + videos + websites)
    if quoteds_tweets.present?
      images += self.generate_images(tweets: quoteds_tweets, options: options)
    end
    return images
  end

  def self.constract_image_from_tweet(tweet:, image_url:, options: {})
    tweet_text = Sanitizer.basic_sanitize(tweet.text)
    tweet_text = Sanitizer.delete_urls(tweet_text)
    image = self.constract(
      url: image_url.to_s,
      title: tweet_text,
      check_file: false,
      options: {
        tweet_id: tweet.id
      }.merge(options)
    )
    return image
  end

  def self.constract_from_tweet(tweet:)
    return [] unless tweet.media?
    tweet_text = Sanitizer.basic_sanitize(tweet.text)
    tweet_text = Sanitizer.delete_urls(tweet_text)

    videos = tweet.media.flat_map do |m|
      case m
      when Twitter::Media::Video
        max_bitrate_variant = m.video_info.variants.max_by{|variant| variant.bitrate.to_i }
        video = Datapool::TwitterVideoMetum.new(
          title: tweet_text,
          front_image_url: m.media_url.to_s,
          data_category: :file,
          bitrate: max_bitrate_variant.try(:bitrate),
          options: {duration: m.video_info.duration_millis}
        )
        video.src = max_bitrate_variant.try(:url).to_s
        video
      else
        []
      end
    end
    return videos
  end
end
