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

ActiveRecord::Schema[8.1].define(version: 2026_06_30_142000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contact_requests", force: :cascade do |t|
    t.string "company_name"
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "error_message"
    t.string "job_title"
    t.string "locale", default: "pt", null: false
    t.string "request_ip"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["email"], name: "index_contact_requests_on_email"
    t.index ["status"], name: "index_contact_requests_on_status"
  end

  create_table "educations", force: :cascade do |t|
    t.json "courses", default: {}, null: false
    t.datetime "created_at", null: false
    t.json "institutions", default: {}, null: false
    t.integer "portfolio_profile_id", null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.json "statuses", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_profile_id", "position"], name: "index_educations_on_portfolio_profile_id_and_position"
    t.index ["portfolio_profile_id"], name: "index_educations_on_portfolio_profile_id"
  end

  create_table "experiences", force: :cascade do |t|
    t.string "company", null: false
    t.datetime "created_at", null: false
    t.json "locations", default: {}, null: false
    t.string "period", null: false
    t.integer "portfolio_profile_id", null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.json "roles", default: {}, null: false
    t.json "summaries", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_profile_id", "position"], name: "index_experiences_on_portfolio_profile_id_and_position"
    t.index ["portfolio_profile_id"], name: "index_experiences_on_portfolio_profile_id"
  end

  create_table "highlights", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "descriptions", default: {}, null: false
    t.string "metric"
    t.integer "portfolio_profile_id", null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.json "titles", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_profile_id", "position"], name: "index_highlights_on_portfolio_profile_id_and_position"
    t.index ["portfolio_profile_id"], name: "index_highlights_on_portfolio_profile_id"
  end

  create_table "portfolio_documents", force: :cascade do |t|
    t.json "bodies", default: {}, null: false
    t.string "content_kind", default: "custom", null: false
    t.datetime "created_at", null: false
    t.integer "portfolio_profile_id", null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.json "titles", default: {}, null: false
    t.datetime "updated_at", null: false
    t.boolean "uses_resume", default: false, null: false
    t.index ["portfolio_profile_id", "content_kind"], name: "idx_on_portfolio_profile_id_content_kind_cab0839794"
    t.index ["portfolio_profile_id", "position"], name: "index_portfolio_documents_on_portfolio_profile_id_and_position"
    t.index ["portfolio_profile_id"], name: "index_portfolio_documents_on_portfolio_profile_id"
  end

  create_table "portfolio_profiles", force: :cascade do |t|
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.json "email_bodies", default: {}, null: false
    t.json "email_subjects", default: {}, null: false
    t.string "full_name", null: false
    t.string "github_url"
    t.string "linkedin_url"
    t.json "locations", default: {}, null: false
    t.json "map_labels", default: {}, null: false
    t.decimal "map_x_percent", precision: 5, scale: 2, default: "35.0", null: false
    t.decimal "map_y_percent", precision: 5, scale: 2, default: "60.0", null: false
    t.string "nickname"
    t.json "philosophies", default: {}, null: false
    t.string "phone"
    t.json "roles", default: {}, null: false
    t.json "summaries", default: {}, null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string "category", default: "backend", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.boolean "featured", default: true, null: false
    t.string "name", null: false
    t.integer "portfolio_profile_id", null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_profile_id", "position"], name: "index_skills_on_portfolio_profile_id_and_position"
    t.index ["portfolio_profile_id"], name: "index_skills_on_portfolio_profile_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "educations", "portfolio_profiles"
  add_foreign_key "experiences", "portfolio_profiles"
  add_foreign_key "highlights", "portfolio_profiles"
  add_foreign_key "portfolio_documents", "portfolio_profiles"
  add_foreign_key "skills", "portfolio_profiles"
end
