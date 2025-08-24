# Generic class, should NOT use directly
class Document < ApplicationRecord
  include Document::Fetchable, Document::Transformable, Document::Packageable

  BASE_DIR = Pathname(Rails.root.join("storage", "highpoint")).freeze

  has_many :resources, dependent: :destroy
  has_one :pubs2, -> { where(kind: :pubs2) }, class_name: "Resource"
  has_one :pubs12, -> { where(kind: :pubs12) }, class_name: "Resource"
  has_one :pdf, -> { where(kind: :pdf) }, class_name: "Resource"
  has_many :images, -> { where(kind: :image) }, class_name: "Resource"

  scope :capnet, -> { where(system: "capnet") }
  scope :legacy, -> { where(system: "legacy") }

  scope :fetched, -> { where.not(fetched_at: nil) }
  scope :not_fetched, -> { where(fetched_at: nil) }
  scope :transformed, -> { where.not(transformed_at: nil) }
  scope :not_transformed, -> { where(transformed_at: nil) }
  scope :packaged, -> { transformed.where.not(packaged_at: nil) }
  scope :not_packaged, -> { where(packaged_at: nil) }

  validates :doc_num, presence: true
  validates :url, presence: true
  validates :doc_num, uniqueness: { scope: :system }

  def base_dir
    BASE_DIR.join(system)
  end

  def raw_dir
    base_dir.join("raw", doc_num)
  end

  def raw_attach_dir
    raw_dir.join("attach")
  end

  def transformed_dir
    base_dir.join("transformed", doc_num)
  end

  def transformed_attach_dir
    transformed_dir.join("attach")
  end

  def packaged_zip_path
    base_dir.join("packaged", "#{doc_num}.zip")
  end

  def pubs12_ok?
    pubs12&.ok? && File.exist?(pubs12.file_path.to_s)
  end

  def transformed?
    transformed_at.present? && File.exist?(transformed_dir.join("#{doc_num}.xml"))
  end

  def packaged?
    packaged_at.present? && File.exist?(packaged_zip_path)
  end

  def pubs2_url
    url
      .gsub("/attachment/fs/", "/transformer/")
      .gsub("/attachments/", "/transformer/")
      .gsub("/attachment/", "/transformer/")
      .gsub("/exist/", "/transformer/")
      .gsub(".html", ".xml")
  end

  def pubs12_url
    pubs2_url.gsub("/transformer/", "/transformer/pubs12/")
  end

  def pdf_url
    url.gsub(".html", ".pdf")
  end



  # def system_dir
  #   raise NotImplementedError, "System Document class must define this!"
  # end

  # scope :fetched, -> { where.not(fetched_at: nil) }
  # scope :not_fetched, -> { where(fetched_at: nil) }
  # scope :transformed, -> { fetched.where.not(transformed_at: nil) }
  # scope :not_transformed, -> { where(transformed_at: nil) }
  # scope :packaged, -> { transformed.where.not(packaged_at: nil) }
  # scope :not_packaged, -> { where(packaged_at: nil) }

  # scope :pubs2, -> { where(pubs2: true) }
  # scope :pubs5, -> { where(pubs5: true) }
  # scope :pubs12, -> { where(pubs12: true) }
  # scope :pdf, -> { where(pdf: true) }

  # scope :transformable, -> { fetched.pubs12.or(fetched.pubs5) }

  # def self.fetch_all_in_background!
  #   self.find_each(batch_size: 500) do |document|
  #     FetchJob.perform_later(document)
  #   end
  # end

  # def self.transform_all!
  #   self.transformable.each do |document|
  #     document.transform!
  #   end
  # end

  # def self.package_all!
  #   self.transformed.each do |document|
  #     document.package!
  #   end
  # end

  # def fetch!

  # end

  # def transform!
  #   pubs12_resource.transform!
  # end

  # def package!

  # end

  # def raw_dir
  #   system_dir.join("raw", doc_num)
  # end

  # def raw_attach_dir
  #   raw_dir.join("attach")
  # end

  # def transformed_dir
  #   system_dir.join("transformed", doc_num)
  # end

  # def transformed_attach_dir
  #   transformed_dir.join("attach")
  # end

  # def packaged_dir
  #   system_dir.join("packaged", doc_num)
  # end

  # def packaged_file_path
  #   packaged_dir.join("#{doc_num}.zip")
  # end
end
