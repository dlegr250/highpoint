module Ingestable
  extend ActiveSupport::Concern

  class_methods do
    def load_file!(path:, system:)
      ext = File.extname(path).downcase
      case ext
      when ".csv"   then load_csv!(path, system:)
      when ".xlsx", ".xls" then load_xlsx!(path, system:)
      else raise "Unsupported file type: #{ext}"
      end
    end

    def load_csv!(path, system:)
      CSV.foreach(path, headers: true) do |row|
        upsert(row["doc_num"], row["url"], system)
      end
    end

    def load_xlsx!(path, system:)
      spreadsheet = Roo::Spreadsheet.open(path)
      sheet = spreadsheet.sheet(0)
      headers = sheet.row(1).map(&:to_s)
      doc_header = headers.index("doc_num")
      url_header = headers.index("url")
      raise "Missing headers doc_num/url" unless doc_header && url_header
      (2..sheet.last_row).each do |r|
        upsert(sheet.row(r)[doc_header].to_s, sheet.row(r)[url_header].to_s, system)
      end
    end

    def upsert(doc_num, url, system)
      Document.find_or_create_by!(system:, doc_num:) { |document| document.source_url = url }
    end
  end
end
