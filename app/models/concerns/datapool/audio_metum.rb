module Datapool::AudioMetum
  AUDIO_FILE_EXTENSIONS = [
    #https://ja.wikipedia.org/wiki/AIFF
    ".aiff",".aif", ".aifc", ".afc",
    ".mp3",
    ".wav",
    #https://ja.wikipedia.org/wiki/Vorbis
    ".ogg", ".oga",
    #https://ja.wikipedia.org/wiki/Opus_(%E9%9F%B3%E5%A3%B0%E5%9C%A7%E7%B8%AE)
    ".opus",
    #https://ja.wikipedia.org/wiki/AAC
    "m2ts",".m4b",".aac",
    #https://ja.wikipedia.org/wiki/ATRAC
    ".omg", ".oma", ".aa3",
    #https://ja.wikipedia.org/wiki/FLAC
    ".flac", ".fla",
    ".mpc",
    ".ape", ".mac",
    #https://ja.wikipedia.org/wiki/TTA
    ".tta",
    #https://ja.wikipedia.org/wiki/WavPack
    ".wv",
    #https://ja.wikipedia.org/wiki/La_(%E9%9F%B3%E5%A3%B0%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88)
    ".la",
    #https://ja.wikipedia.org/wiki/Apple_Lossless
    ".alac"
  ]

  def save_filename
    if self.original_filename.present?
      return self.original_filename
    end
    return super.save_filename
  end

  def self.new_audio(audio_url:, title:, file_genre: , options: {})
    audio_metum = self.new(
      title: title,
      file_genre: file_genre,
      options: {}.merge(options)
    )
    audio_metum.src = audio_url
    if file_genre.blank?
      if audio_metum.type == "Datapool::YoutubeAudioMetum" || audio_metum.type == "Datapool::NiconicoAudioMetum"
        audio_metum.data_category = "video_streaming"
      elsif Datapool::VideoMetum.videofile?(audio_metum.src)
        audio_metum.data_category = "video_file"
      else
        audio_metum.data_category = "audio_file"
      end
    end
    filename = self.match_filename(audio_metum.src.to_s)
    audio_metum.set_original_filename(filename)
    return audio_metum
  end

  def self.audiofile?(url)
    return AUDIO_FILE_EXTENSIONS.any?{|ext| File.extname(url).downcase.start_with?(ext) }
  end
end