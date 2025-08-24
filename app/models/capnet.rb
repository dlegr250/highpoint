class Capnet
  include Ingestable

  def self.fetch!(only_missing: true)
    documents = if only_missing
      Document.capnet.where.missing(:resources)
    else
      Document.capnet
    end

    documents.find_each { |d| d.enqueue_fetch!(queue: :capnet) }
  end

  def self.transform!
    Document.capnet.where(id: ready_to_transform_ids).find_each { |d| d.transform! }
  end

  def self.package!
    Document.capnet.where(id: ready_to_package_ids).find_each { |d| d.package! }
  end

  def self.push_s3!(stage:, bucket:)
    dir = base_dir.join(stage.to_s)
    # TODO: use S3 KMS keys and key id params
    system("aws", "s3", "sync", dir.to_s, "s3://#{bucket}/highpoint/capnet/#{stage}")
  end

  def self.base_dir
    Document::BASE_DIR.join(:capnet)
  end

  def self.ready_to_transform_ids
    Document.capnet.includes(:pubs12).select(&:pubs12_ok?).map!(&:id)
  end

  def self.ready_to_package_ids
    Document.capnet.transformed.not_packaged.pluck(:id)
  end
end
