module Datapool::PdfMetum
  def self.pdffile?(filename)
    return File.extname(filename).downcase.start_with?(".pdf")
  end

  def self.invlide_file?(url:)
    begin
      pdf_io = Kernel.open(url.to_s)
      PDF::Reader.new(pdf_io)
    rescue Errno::ENOENT => e
      Rails.logger.warn("#{url} url error!!:" + e.message)
      return true
    rescue PDF::Reader::MalformedPDFError => e
      Rails.logger.warn("it is not pdf:" + url.to_s)
      return true
    end
    return false
  end
end