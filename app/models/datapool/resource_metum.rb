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
    unknown: 0,
    image: 1,
    video: 2,
    audio: 3,
    pdf: 4,
    threed_model: 5,
    text: 6
  }

  S3_ROOT_URL = "https://taptappun.s3.amazonaws.com/"

  def self.match_filename(filepath)
    paths = filepath.split("/")
    resourcefile_name = paths.detect{|p| self.file_extensions.any?{|ie| p.include?(ie)} }
    return "" if resourcefile_name.blank?
    ext = self.file_extensions.detect{|ie| resourcefile_name.include?(ie) }
    return resourcefile_name.match(/(.+?#{ext})/).to_s
  end

  def filename=(filepath)
    self.original_filename = Datapool::ResourceMetum.match_filename(filepath)
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
      return "backup/crawler/pdfs/"
    elsif self.threed_model?
      return "backup/crawler/threed_models/"
    else
      return "backup/crawler/resources/"
    end
  end

  def self.constract(url:, title:, check_file: false, options: {})
    url.strip!
    sanitized_title = Sanitizer.basic_sanitize(title)
    new_resource_class = self.new
    new_resource_class.src = url
    new_resource_class.title = sanitized_title
    new_resource_class.set_correct_genre
    return new_resource_class
  end

  def self.import_resources!(resources:)
    src_resources = self.find_origin_src_by_url(url: imports.map(&:src).uniq).index_by(&:src)
    import_resources = imports.select{|imp| src_resources[imp.src].blank? }.uniq(&:src)
    if import_resources.present?
      clazz.import!(import_resources)
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