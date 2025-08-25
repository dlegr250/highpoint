module Document::Fetchable
  include ActiveSupport::Concern

  def enqueue_fetch!
    FetchDocumentJob.perform_later(id)
  end

  def fetch_resources!
    FileUtils.mkdir_p(raw_attach_dir)

    ensure_core_resources!

    # Download XMLs and PDF first
    [pubs12, pubs2, pdf].compact.each do |resource|
      resource.download_to!(raw_path_for(resource))
    end

    chosen_xml = pubs12_ok? ? pubs12 : pubs2
    if chosen_xml&.ok?
      img_urls = extract_image_urls(chosen_xml.file_path)
      ensure_image_resources!(img_urls)
      images.find_each { |img| img.download_to!(raw_path_for(img)) }
    end

    touch(:fetched_at)
    self
  end

  def ensure_core_resources!
    resources.create!(kind: :pubs12, url: pubs12_url) unless pubs12
    resources.create!(kind: :pubs2, url: pubs2_url) unless pubs2
    resources.create!(kind: :pdf, url: pdf_url) unless pdf
  end

  def ensure_image_resources!(urls)
    existing = images.pluck(:url).to_set
    urls.each do |url|
      next if existing.include?(url)
      resources.create!(kind: :image, url: url)
    end
  end

  def extract_image_urls(xml_path)
    xml = File.read(xml_path)
    doc = Nokogiri::XML(xml) { |cfg| cfg.strict.nonet.recover }
    doc.xpath("//MediaResource//StillImageExhibit[@href]").map { |n| n["href"].to_s }.uniq
  rescue => e
    Rails.logger.error("image url extract failed #{id}: #{e.class}: #{e.message}")
    []
  end

  def raw_path_for(resource)
    case resource.kind.to_sym
    when :pubs2 then raw_dir.join("#{doc_num}.pubs2.xml")
    when :pubs12 then raw_dir.join("#{doc_num}.pubs12.xml")
    when :pdf then attach_dir.join("#{doc_num}.pdf")
    when :image
      fname = URI(resource.url).path.split("/").last.presence || "img-#{SecureRandom.hex(4)}"
      raw_attach_dir.join(fname)
    else
      raw_dir.join("#{doc_num}-#{resource.kind}")
    end
  end
end
