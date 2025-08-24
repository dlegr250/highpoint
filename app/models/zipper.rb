class Zipper
  def self.zip_dir(src_dir, zip_path)
    FileUtils.mkdir_p(File.dirname(zip_path))
    src_dir = Pathname(src_dir)

    Zip::File.open(zip_path.to_s, Zip::File::CREATE) do |zipfile|
      Dir[File.join(src_dir, '**', '**')].each do |file|
        next if File.directory?(file)
        entry = file.delete_prefix(src_dir.to_s + "/")
        zipfile.add(entry, file)
      end
    end
  end
end
