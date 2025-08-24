class Capnet
  def self.load_csv!(path)
    CSV.foreach(path, headers: true) do |row|
      Document.find_or_create_by!(system: :capnet, doc_num: row.fetch("doc_num")) do |d|
        d.source_url = row.fetch("url")
      end
    end
  end

  def self.fetch!(only_missing: true)
    scope = Document.capnet
    scope = scope.where.missing(:resources) if only_missing
    scope.find_each { |d| d.enqueue_fetch!(queue: :capnet) }
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
    Document.capnet.includes(:xml2).select(&:xml2_ok?).map!(&:id)
  end

  def self.ready_to_package_ids
    Document.capnet.transformed.not_packaged.pluck(:id)
  end
end
