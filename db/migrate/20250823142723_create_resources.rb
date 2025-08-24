class CreateResources < ActiveRecord::Migration[8.0]
  def change
    create_table :resources do |t|
      t.belongs_to :document, null: false, foreign_key: true
      t.string :kind, null: false
      t.text :url, null: false
      t.text :file_path
      t.string :status, null: false, default: "pending"
      t.integer :http_status
      t.text :error

      t.timestamps
    end

    add_index :resources, [:document_id, :kind]
    add_index :resources, :status
  end
end
