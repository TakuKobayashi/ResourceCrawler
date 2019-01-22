module Datapool::ImageMetum
  #after_destroy do
  #  if self.src.include?(Datapool::ResourceMetum::S3_ROOT_URL)
  #    s3 = Aws::S3::Client.new
  #    s3.delete_object(bucket: "taptappun", key: self.src.gsub(Datapool::ResourceMetum::S3_ROOT_URL, ""))
  #  end
  #end

  IMAGE_FILE_EXTENSIONS = [
    ".agp",
    ".ai", #Illustrator
    ".cdr",
    ".cpc", ".cpi",
    ".eps",
    ".eri",
    ".gif", #GIF
    ".iff", ".ilbm", ".lbm",
    ".ima",
    ".jpg", ".jpeg", #JPEG
    ".jxr", ".hdp", ".wdp",
    ".jp2", ".j2c",
    ".mki",
    ".mag",
    ".pi",
    ".pict", ".pic", ".pct",
    ".pdf", #PDF
    ".png", #PNG
    ".psd", ".psb", ".pdd", #PSD
    ".psp",
    ".svg", #SVG
    ".tga", ".tpic", #TGA 3Dモデルのテクスチャーとかによく使われる
    ".tif", #tif 文字とかフォントとか
    ".webp",
    ".bmp", #BMP
  ]

  CRAWL_IMAGE_ROOT_PATH = "project/crawler/images/"
  CRAWL_IMAGE_BACKUP_PATH = "backup/crawler/images/"

  def self.imagefile?(url)
    aurl = Addressable::URI.parse(url.to_s)
    return IMAGE_FILE_EXTENSIONS.any?{|ext| File.extname(aurl.path).downcase.start_with?(ext) } || aurl.scheme == "data"
  end

  def self.file_extensions
    return IMAGE_FILE_EXTENSIONS
  end

  def save_filename
    if self.original_filename.present?
      return self.original_filename
    end
    return super.save_filename
  end

  # Google Reverse Image Serachする
  def self.search_reverse_image_url(image_url:)
    search_url = Addressable::URI.parse("https://images.google.com/searchbyimage")
    search_url.query_values = {image_url: image_url}
    return search_url.to_s
  end

  def convert_to_base64
    filepath = self.src
    ext = File.extname(filepath)
    s3 = Aws::S3::Client.new
    binary = s3.get_object(bucket: "taptappun",key: filepath)
    base64_image = Base64.strict_encode64(binary.body.read)
    return "data:image/" + ext[1..ext.size] + ";base64," + base64_image
  end

  def self.invlide_file?(url:)
    # 画像じゃないものも含まれていることもあるので分別する
    begin
      image_type = FastImage.type(url.to_s)
    rescue URI::InvalidComponentError => e
      Rails.logger.warn("#{url} url error!!:" + e.message)
      return true
    end
    if image_type.blank?
      Rails.logger.warn("it is not image:" + aimage_url.to_s)
      return true
    end
    return false
  end

  def self.calc_resize_text(width:, height:, max_length:)
    if width > height
      resized_width = [width, max_length].min
      resized_height = ((resized_width.to_f / width.to_f) * height.to_f).to_i
      return "#{resized_width.to_i}x#{resized_height.to_i}"
    else
      resized_height = [height, max_length].min
      resized_width = ((resized_height.to_f / height.to_f) * width.to_f).to_i
      return "#{resized_width.to_i}x#{resized_height.to_i}"
    end
  end

  def self.backup!
    Datapool::ImageMetum.find_in_batches do |images|
      not_backup_images = images.select{|image| image.options["image_backuped"].blank? }
      next if not_backup_images.blank?
      self.write_image_buckup_log("#{not_backup_images.size} images backup start!!\n first id:#{not_backup_images.first.try(:id)} last id:#{not_backup_images.last.try(:id)}")
      Tempfile.create(SecureRandom.hex) do |tempfile|
        zippath = ResourceUtility.download_and_compress_to_zip(zip_filepath: tempfile.path, resources: not_backup_images)
        s3 = Aws::S3::Client.new
        filepath = CRAWL_IMAGE_BACKUP_PATH + "#{Time.current.strftime("%Y%m%d_%H%M%S%L")}.zip"
        s3.put_object(bucket: "taptappun",body: File.open(zippath), key: filepath)
      end
      self.write_image_buckup_log("#{not_backup_images.size} images upload complete!!\n first id:#{not_backup_images.first.try(:id)} last id:#{not_backup_images.last.try(:id)}")
      self.transaction do
        not_backup_images.each do |image|
          image.options["image_backuped"] = true
          image.save!
        end
      end
    end
  end

  def self.write_image_buckup_log(log_message)
    File.open("#{Rails.root}/log/image_backup.log", 'a') do |file|
      file.write(log_message.to_s)
    end
  end
end