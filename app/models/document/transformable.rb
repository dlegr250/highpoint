module Document::Transformable
  include ActiveSupport::Concern

  def transform!
    raise "PUBS12 required" unless pubs12_ok?

    FileUtils.mkdir_p(transformed_attach_dir)

    # Transform FROM PUBS12 into single <doc_num>.xml
    pubs12_path = raw_dir.join("#{doc_num}.pubs12.xml")
    raise "missing PUBS12 raw file" unless File.exist?(pubs12_path)

    transformed_xml = transform_xml(File.read(pubs12_path))
    File.write(transformed_dir.join("#{doc_num}.xml"), transformed_xml)

    # Copy attachments from raw as-is
    if Dir.exist?(raw_attach_dir)
      FileUtils.cp_r(Dir.glob(raw_attach_dir.join("*")), transformed_attach_dir)
    end

    touch(:transformed_at)
    self
  end

  # stub, replace with real mapping
  def transform_xml(xml)
    xml # no-op placeholder
  end
end
