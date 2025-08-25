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

    begin
      response = HttpClient.get(url)

      if response.http_status == 200
        File.binwrite(dest_path, response.body)
        self.http_status = response.status
        self.file_path = dest_path.to_s
        self.status = :ok
        save!
      else
        self.status = :failed
        self.http_status = response.status
        self.error_message = response&.body.to_s
        save!
      end
    rescue => e
      self.status = :failed
      self.error_message = "#{e.class}: #{e.message}"
      save!
    end

    self
  end

  def ok?
    status == "ok"
  end
end
