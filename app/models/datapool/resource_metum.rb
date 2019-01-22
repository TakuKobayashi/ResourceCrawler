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

class Datapool::ResourceMetum < Datapool::ResourceBase
  serialize :options, JSON

  enum appear_state: {
    appearing: 0,
    mismatch: 1,
    notfound: 2,
    disappeared: 3,
    error: 9,
  }

  enum resource_genre: {
    unknown: 0,
    image: 1,
    video: 2,
    audio: 3,
    pdf: 4,
    threed_model: 5,
    compressed: 6,
    text: 7
  }

  has_one :resource_extend, class_name: 'Datapool::ResourceExtend', foreign_key: :datapool_resource_meta_id
  has_many :resource_keywords, class_name: 'Datapool::ResourceKeyword', primary_key: :uuid, foreign_key: :datapool_resource_metum_uuid
  has_many :job_resources, class_name: 'JobResource', primary_key: :uuid, foreign_key: :resource_meta_uuid
  has_many :childrens, class_name: 'Datapool::ResourceFamily', primary_key: :uuid, foreign_key: :parent_resource_uuid

  S3_ROOT_URL = "https://taptappun.s3.amazonaws.com/"

  def self.resource_file_extensions
    return ([".pdf"] |
      Datapool::AudioMetum::AUDIO_FILE_EXTENSIONS |
      Datapool::ImageMetum::IMAGE_FILE_EXTENSIONS |
      Datapool::VideoMetum::VIDEO_FILE_EXTENSIONS |
      Datapool::ThreedModelMetum::THREED_MODEL_FILE_EXTENSIONS |
      Datapool::CompressedMetum::COMPRESSED_FILE_EXTENSIONS)
  end

  def self.suggest_genre(url)
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
    elsif Datapool::CompressedMetum.compressed_file?(url)
      return :compressed
    else
      return :unknown
    end
  end

  def self.constract(url:, title:, options: {})
    correct_url = url.strip
    sanitized_title = Sanitizer.basic_sanitize(title)
    new_resource_class = self.new
    new_resource_class.uuid = SecureRandom.hex(32)
    if Datapool::YoutubeResourceMetum.youtube?(correct_url)
      new_resource_class = Datapool::YoutubeResourceMetum.new
    elsif Datapool::NiconicoMetum.niconico_video?(correct_url)
      new_resource_class = Datapool::NiconicoMetum.new
    end
    new_resource_class.title = sanitized_title
    new_resource_class.appear_state = :appearing
    new_resource_class.resource_genre = new_resource_class.class.suggest_genre(correct_url)
    new_resource_class.filename = correct_url
    new_resource_class.src = correct_url
    new_resource_class.options = options
    return new_resource_class
  end

  def filename
    return self.original_filename.to_s
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
    elsif self.compressed?
      return "project/crawler/compressed/"
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
    elsif self.compressed?
      return "project/crawler/compressed/"
    else
      return "backup/crawler/resources/"
    end
  end

  def exist_backup?
    return backup_url.present?
  end

  def backup!
    if self.exist_backup?
      return false
    end
    ext = File.extname(self.filename)
    plane_filename = self.filename.gsub(ext, "")
    filepath = self.s3_backup_path + [plane_filename, SecureRandom.hex].join("_") + ext
    s3 = Aws::S3::Client.new
    Tempfile.create(SecureRandom.hex(32)) do |tempfile|
      self.download_resource do |chunk|
        tempfile.write(chunk)
      end
      checksum = Digest::MD5.hexdigest(tempfile)
      result = s3.put_object(bucket: "taptappun", body: tempfile, key: filepath)
      update!(backup_url: S3_ROOT_URL + filepath, md5sum: checksum)
    end
  end

  def download_resource(&block)
    http_client = HTTPClient.new
    http_client.receive_timeout = 60 * 120
    result = http_client.get_content(self.src) do |chunk|
      block.call(chunk)
    end
    return result
  end
end
