module Datapool::PdfMetum
  def self.pdffile?(filename)
    return File.extname(filename).downcase.start_with?(".pdf")
  end

  def self.new_pdf(pdf_url:, title:, check_pdf_file: false, options: {})
    apdf_url = Addressable::URI.parse(pdf_url.to_s)
    image_type = nil
    if check_pdf_file
      # PDFじゃないものも含まれていることもあるので分別する
      begin
        pdf_io = Kernel.open(apdf_url.to_s)
        PDF::Reader.new(pdf_io)
      rescue Errno::ENOENT => e
        Rails.logger.warn("#{pdf_url} url error!!:" + e.message)
        return nil
      rescue PDF::Reader::MalformedPDFError => e
        Rails.logger.warn("it is not pdf:" + apdf_url.to_s)
        return nil
      end
    end
    pdf = self.new(title: title.to_s.truncate(255), options: options)
    pdf.src = apdf_url.to_s
    pathes = pdf.src.split("/")
    pdf.set_original_filename(pathes[pathes.size - 1])
    return pdf
  end
end