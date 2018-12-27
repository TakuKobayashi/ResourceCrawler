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

class Datapool::ResourceMetum < Datapool::ResourceBase
  serialize :options, JSON

  enum resource_genre: {
    unknown: 0,
    image: 1,
    video: 2,
    audio: 3,
    pdf: 4,
    threed_model: 5,
    text: 6
  }

  S3_ROOT_URL = "https://taptappun.s3.amazonaws.com/"

  def filename
    return self.original_filename.to_s
  end


  def self.resource_file_extensions
    return ([".pdf"] |
      Datapool::AudioMetum::AUDIO_FILE_EXTENSIONS |
      Datapool::ImageMetum::IMAGE_FILE_EXTENSIONS |
      Datapool::VideoMetum::VIDEO_FILE_EXTENSIONS |
      Datapool::ThreedModelMetum::THREED_MODEL_FILE_EXTENSIONS)
  end

  def filename=(filepath)
    paths = filepath.split("/")
    file_extensions = Datapool::ResourceMetum.resource_file_extensions
    resourcefile_name = paths.detect{|p| file_extensions.any?{|ie| p.include?(ie)} }
    if resourcefile_name.present?
      ext = file_extensions.detect{|ie| resourcefile_name.include?(ie) }
      self.original_filename = resourcefile_name.match(/(.+?#{ext})/).to_s
    else
      self.original_filename = SecureRandom.hex + File.extname(filename)
    end
  end

  def s3_root_path
    if self.image?
      return "project/crawler/images/"
    elsif self.video?
      return "project/crawler/videos/"
    elsif self.audio?
      return "project/crawler/audios/"
    elsif self.pdf?
      return "project/crawler/pdfs/"
    elsif self.threed_model?
      return "project/crawler/threed_models/"
    else
      return "project/crawler/resources/"
    end
  end

  def s3_backup_path
    if self.image?
      return "backup/crawler/images/"
    elsif self.video?
      return "backup/crawler/videos/"
    elsif self.audio?
      return "backup/crawler/audios/"
    elsif self.pdf?
      return "backup/crawler/pdfs/"
    elsif self.threed_model?
      return "backup/crawler/threed_models/"
    else
      return "backup/crawler/resources/"
    end
  end

  def suggest_genre
    url = self.src
    if Datapool::ImageMetum.imagefile?(url)
      return :image
    elsif Datapool::VideoMetum.videofile?(url)
      return :video
    elsif Datapool::AudioMetum.audiofile?(url)
      return :audio
    elsif Datapool::PdfMetum.pdffile?(url)
      return :pdf
    elsif Datapool::ThreedModelMetum.threed_model?(url)
      return :threed_model
    else
      return :unknown
    end
  end

  def self.constract(url:, title:, check_file: false, options: {})
    url.strip!
    sanitized_title = Sanitizer.basic_sanitize(title)
    new_resource_class = self.new
    new_resource_class.src = url
    new_resource_class.title = sanitized_title
    new_resource_class.resource_genre = new_resource_class.suggest_genre
    new_resource_class.filename = url
    return new_resource_class
  end

  def self.import_resources!(resources:)
    src_resources = self.find_origin_src_by_url(url: imports.map(&:src).uniq).index_by(&:src)
    import_resources = imports.select{|imp| src_resources[imp.src].blank? }.uniq(&:src)
    if import_resources.present?
      clazz.import!(import_resources)
    end
  end

  def download_resource
    return RequestParser.request_and_response_body(url: self.src.to_s, options: {:follow_redirect => true})
  end
end
