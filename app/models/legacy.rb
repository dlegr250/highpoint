class Legacy
  include Ingestable

  def self.fetch!(only_missing: true)
    documents = if only_missing
      Document.legacy.where.missing(:resources)
    else
      Document.legacy
    end

    documents.find_each { |d| d.enqueue_fetch! }
  end

  def self.transform!
    Document.legacy.where(id: ready_to_transform_ids).find_each { |d| d.transform! }
  end

  def self.package!
    Document.legacy.where(id: ready_to_package_ids).find_each { |d| d.package! }
  end

  def self.push_s3!(stage:)
    dir = base_dir.join(stage.to_s)
    # TODO: use S3 KMS keys and key id params
    system("aws", "s3", "sync", dir.to_s, "s3://shared-bucket-name/highpoint/legacy/#{stage}")
  end

  def self.base_dir
    Document::BASE_DIR.join(:legacy)
  end

  def self.ready_to_transform_ids
    Document.legacy.includes(:pubs12).select(&:pubs12_ok?).map(&:id)
  end

  def self.ready_to_package_ids
    Document.legacy.transformed.not_packaged.pluck(:id)
  end
end
