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

class Datapool::ResourceMetum < Datapool::ResourceBase
  serialize :options, JSON

  enum resource_genre: {
    image: 0,
    video: 1,
    audio: 2,
    pdf: 3,
    threed_model: 4,
    text: 5,
    others: 6,
  }

  S3_ROOT_URL = "https://taptappun.s3.amazonaws.com/"

  CRAWL_RESOURCE_ROOT_PATH = "project/crawler/resources/"
  CRAWL_RESOURCE_BACKUP_PATH = "backup/crawler/resources/"

  def directory_name
    return "resources"
  end

  def self.file_extensions
    return []
  end

  def self.match_filename(filepath)
    paths = filepath.split("/")
    resourcefile_name = paths.detect{|p| self.file_extensions.any?{|ie| p.include?(ie)} }
    return "" if resourcefile_name.blank?
    ext = self.file_extensions.detect{|ie| resourcefile_name.include?(ie) }
    return resourcefile_name.match(/(.+?#{ext})/).to_s
  end

  def self.constract(url:, title:, check_file: false, file_genre: nil, priority_check_class: nil, options: {})
    url.strip!
    sanitized_title = Sanitizer.basic_sanitize(title)
    new_resource_class = nil
    if priority_check_class.present?
      new_resource_class = priority_check_class.to_s.constantize.constract(
        url: url,
        title: sanitized_title,
        priority_check_class: nil,
        check_file: check_file,
        file_genre: file_genre,
        options: options
      )
      return new_resource_class
    end
    if Datapool::ImageMetum.imagefile?(url)
      if self.base_class.to_s == "Datapool::ImageMetum"
        new_resource_class = self.new_image(image_url: url, title: sanitized_title, check_image_file: check_file, options: options)
      else
        new_resource_class = Datapool::WebSiteImageMetum.new_image(image_url: url, title: sanitized_title, check_image_file: check_file, options: options)
      end
      if new_resource_class.present?
        return new_resource_class
      end
    end
    if Datapool::PdfMetum.pdffile?(url)
      if self.base_class.to_s == "Datapool::PdfMetum"
        new_resource_class = self.new_pdf(pdf_url: url, title: sanitized_title, check_pdf_file: check_file, options: options)
      else
        new_resource_class = Datapool::PdfMetum.new_pdf(pdf_url: url, title: sanitized_title, check_pdf_file: check_file, options: options)
      end
      if new_resource_class.present?
        return new_resource_class
      end
    end
    if Datapool::VideoMetum.videofile?(url)
      if self.base_class.to_s == "Datapool::VideoMetum"
        new_resource_class = self.new_video(video_url: url, title: sanitized_title, file_genre: file_genre, options: options)
      else
        video_clazz = Datapool::WebSiteVideoMetum
        if Datapool::YoutubeVideoMetum.youtube?(url)
          video_clazz = Datapool::YoutubeVideoMetum
        elsif Datapool::NiconicoVideoMetum.niconico_video?(url)
          video_clazz = Datapool::NiconicoVideoMetum
        end
        new_resource_class = video_clazz.new_video(video_url: url, title: sanitized_title, file_genre: file_genre, options: options)
      end
      if new_resource_class.present?
        return new_resource_class
      end
    end
    if Datapool::AudioMetum.audiofile?(url)
      if self.base_class.to_s == "Datapool::AudioMetum"
        new_resource_class = self.new_audio(audio_url: url, title: sanitized_title, file_genre: file_genre, options: options)
      else
        audio_clazz = Datapool::WebSiteAudioMetum
        if Datapool::YoutubeVideoMetum.youtube?(url)
          audio_clazz = Datapool::YoutubeAudioMetum
        elsif Datapool::NiconicoVideoMetum.niconico_video?(url)
          audio_clazz = Datapool::NiconicoAudioMetum
        end
        new_resource_class = audio_clazz.new_audio(audio_url: url, title: sanitized_title, file_genre: file_genre, options: options)
      end
      if new_resource_class.present?
        return new_resource_class
      end
    end
    if self.base_class.to_s == "Datapool::Website"
      new_resource_class = self.new_website(url: url, title: sanitized_title, options: options)
    else
      new_resource_class = Datapool::Website.new_website(url: url, title: sanitized_title, options: options)
    end
    return new_resource_class
  end

  def self.import_resources!(resources:)
    clazz_imports = {}
    resources.each do |resource|
      next unless resource.kind_of?(Datapool::ResourceMetum)
      if resource.kind_of?(Datapool::ImageMetum)
        if clazz_imports[Datapool::ImageMetum].blank?
          clazz_imports[Datapool::ImageMetum] = []
        end
        clazz_imports[Datapool::ImageMetum] << resource
      elsif resource.kind_of?(Datapool::PdfMetum)
        if clazz_imports[Datapool::PdfMetum].blank?
          clazz_imports[Datapool::PdfMetum] = []
        end
        clazz_imports[Datapool::PdfMetum] << resource
      elsif resource.kind_of?(Datapool::AudioMetum)
        if clazz_imports[Datapool::AudioMetum].blank?
          clazz_imports[Datapool::AudioMetum] = []
        end
        clazz_imports[Datapool::AudioMetum] << resource
      elsif resource.kind_of?(Datapool::VideoMetum)
        if clazz_imports[Datapool::VideoMetum].blank?
          clazz_imports[Datapool::VideoMetum] = []
        end
        clazz_imports[Datapool::VideoMetum] << resource
      else
        if clazz_imports[Datapool::Website].blank?
          clazz_imports[Datapool::Website] = []
        end
        clazz_imports[Datapool::Website] << resource
      end
    end

    clazz_imports.each do |clazz, imports|
      src_resources = clazz.find_origin_src_by_url(url: imports.map(&:src).uniq).index_by(&:src)
      import_resources = imports.select{|imp| src_resources[imp.src].blank? }.uniq(&:src)
      if import_resources.present?
        clazz.import!(import_resources)
      end
    end
  end

  def save_filename
    return SecureRandom.hex + File.extname(self.try(:original_filename).to_s)
  end

  def set_original_filename(filename)
    if filename.size > 255
      self.original_filename = SecureRandom.hex + File.extname(filename)
    else
      self.original_filename = filename
    end
  end

  def download_resource
    aurl = Addressable::URI.parse(self.src)
    response_body = RequestParser.request_and_response_body(url: aurl.to_s, options: {:follow_redirect => true})
    return response_body
  end
end
