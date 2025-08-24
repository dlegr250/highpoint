module Document::Packageable
  include ActiveSupport::Concern

  def package!
    raise "not transformed" unless transformed?
    Zipper.zip_dir(transformed_dir, packaged_zip_path)
    touch(:packaged_at)
    self
  end
end
