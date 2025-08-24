class Resource < ApplicationRecord
  belongs_to :document

  validates :url, presence: true
  validate :resource_kinds_are_unique

  def resource_kinds_are_unique
    return unless %w[pubs2 pubs12 pdf].include?(kind)
    if document.resources.where(kind: kind).where.not(id: id).exists?
      errors.add(:kind, "already exists for this document")
    end
  end

  def download_to!(dest_path)
    FileUtils.mkdir_p(File.dirname(dest_path))
    tmp = Pathname(dest_path.to_s + ".tmp")

    begin
      File.open(tmp, "wb") do |io|
        resp = HttpClient.client.get(url, response_body_io: io)
        self.http_status = resp.status
      end

      if http_status == 200
        FileUtils.mv(tmp, dest_path)
        self.file_path = dest_path.to_s
        self.status = :ok
        save!
      else
        self.status = :failed
        self.error_message = "HTTP #{http_status}"
        save!
        FileUtils.rm_f(tmp)
      end
    rescue => e
      self.status = :failed
      self.error_message = "#{e.class}: #{e.message}"
      save!
      FileUtils.rm_f(tmp)
    end

    self
  end

  def ok?
    status == "ok"
  end
end
