class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :system, null: false, default: "Legacy"
      t.string :doc_num, null: false
      t.text :url, null: false
      t.datetime :fetched_at
      t.datetime :transformed_at
      t.datetime :packaged_at

      t.timestamps
    end

    add_index :documents, [:system, :doc_num], unique: true
    add_index :documents, :system
  end
end
