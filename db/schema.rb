# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_23_142723) do
  create_table "documents", force: :cascade do |t|
    t.string "system", default: "Legacy", null: false
    t.string "doc_num", null: false
    t.text "url", null: false
    t.datetime "fetched_at"
    t.datetime "transformed_at"
    t.datetime "packaged_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system", "doc_num"], name: "index_documents_on_system_and_doc_num", unique: true
    t.index ["system"], name: "index_documents_on_system"
  end

  create_table "resources", force: :cascade do |t|
    t.integer "document_id", null: false
    t.string "kind", null: false
    t.text "url", null: false
    t.text "file_path"
    t.string "status", default: "pending", null: false
    t.integer "http_status"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id", "kind"], name: "index_resources_on_document_id_and_kind"
    t.index ["document_id"], name: "index_resources_on_document_id"
    t.index ["status"], name: "index_resources_on_status"
  end

  add_foreign_key "resources", "documents"
end
