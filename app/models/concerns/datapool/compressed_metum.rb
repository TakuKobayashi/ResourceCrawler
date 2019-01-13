module Datapool::CompressedMetum
  COMPRESSED_FILE_EXTENSIONS = [
    # https://en.wikipedia.org/wiki/List_of_archive_formats
    ".zip",
    ".zipx",
    ".tgz",
    ".tar.Z",
    ".tar.bz2",
    ".tar.gz",
    ".tbz2",
    ".tar",
    ".7z",
    ".gz",
  ]

  def self.compressed_file?(url)
    return COMPRESSED_FILE_EXTENSIONS.any?{|ext| File.extname(url).downcase.start_with?(ext) }
  end
end