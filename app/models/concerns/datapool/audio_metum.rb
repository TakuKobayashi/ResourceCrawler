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

  def self.audiofile?(url)
    return AUDIO_FILE_EXTENSIONS.any?{|ext| File.extname(url).downcase.start_with?(ext) }
  end
end