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

class Datapool::FrickrMetum < Datapool::ResourceMetum
  PER_PAGE = 500

  def self.get_flickr_client
    FlickRaw.api_key = ENV.fetch('FLICKR_APIKEY', '')
    FlickRaw.shared_secret = ENV.fetch('FLICKR_SECRET', '')
    return flickr
  end

  def self.search_resources!(search: {})
    flickr_client = self.get_flickr_client
    page_counter = 1
    flickr_resources = []
    resources = []
    resource_counter = 0
    loop do
      flickr_resources = flickr_client.photos.search(search.merge({per_page: PER_PAGE, page: page_counter}))
      resources += self.generate_resources!(flickr_resources: flickr_resources, options: search)
      page_counter = page_counter + 1
      resource_counter += flickr_resources.size
      break if resource_counter >= flickr_resources.total.to_i
    end
    return resources.uniq(&:src)
  end

  private
  def self.generate_resources!(flickr_resources:, options: {})
    url_resources = {}
    flickr_resources.each do |flickr_resource|
      resource_url = FlickRaw.url(flickr_resource)
      next if url_resources[resource_url.to_s].blank?
      resource = self.constract(
        url: resource_url.to_s,
        title: flickr_resource.title,
        options: {
          flicker_secret: flickr_resources.secret,
          flicker_user_id: flickr_resources.owner
        }.merge(options)
      )
      resource.content_id = flickr_resources.id
      url_resources[resource_url.to_s] = resource
    end
    resources = url_resources.values
    self.import_resources!(resources: resources)
    return resources
  end
end
