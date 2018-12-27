module Datapool::VideoMetum
  VIDEO_FILE_EXTENSIONS = [
    #https://ja.wikipedia.org/wiki/Audio_Video_Interleave
    ".avi",
    #https://ja.wikipedia.org/wiki/Advanced_Systems_Format
    ".asf",".wma",".wmv",
    #https://ja.wikipedia.org/wiki/Flash_Video
    ".flv",".f4v",".f4p",".f4a",".f4b",
    #https://ja.wikipedia.org/wiki/Ogg_Media
    ".ogm",
    #https://ja.wikipedia.org/wiki/MPEG-1
    ".dat",".mpg",".mpeg",".m1v",
    #https://ja.wikipedia.org/wiki/MP4
    ".mp4",".m4v",".m4a",".m4p",
    #https://ja.wikipedia.org/wiki/QuickTime
    ".mov",
    #https://ja.wikipedia.org/wiki/RealVideo
    ".rm",".rmvb",".ram",
    #https://ja.wikipedia.org/wiki/XVD
    ".vg2",".vgm",
    #https://ja.wikipedia.org/wiki/Matroska
    ".mkv",".mka",".mks",".mk3d",
    #https://ja.wikipedia.org/wiki/3GPP#3GPP%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88
    ".3gp",
    #https://ja.wikipedia.org/wiki/WebM
    ".webm",
    ".swf"
  ]

  def self.videofile?(url)
    return VIDEO_FILE_EXTENSIONS.any?{|ext| File.extname(url).downcase.start_with?(ext) }
  end
end