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

ActiveRecord::Schema[8.0].define(version: 2025_06_27_130544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "business_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "icon_class"
    t.boolean "active", default: true
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_business_categories_on_active"
    t.index ["name"], name: "index_business_categories_on_name", unique: true
  end

  create_table "business_category_assignments", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.bigint "business_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_category_id"], name: "index_business_category_assignments_on_business_category_id"
    t.index ["business_id", "business_category_id"], name: "index_business_categories_on_business_and_category", unique: true
    t.index ["business_id"], name: "index_business_category_assignments_on_business_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name", null: false
    t.text "description"
    t.string "business_phone"
    t.string "business_email"
    t.string "license_number"
    t.text "areas_served"
    t.string "website_url"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country", default: "United States"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "business_status", default: 0
    t.boolean "featured", default: false
    t.boolean "verified", default: false
    t.json "business_hours"
    t.string "meta_title"
    t.text "meta_description"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_status"], name: "index_businesses_on_business_status"
    t.index ["featured"], name: "index_businesses_on_featured"
    t.index ["latitude", "longitude"], name: "index_businesses_on_latitude_and_longitude"
    t.index ["slug"], name: "index_businesses_on_slug", unique: true
    t.index ["user_id"], name: "index_businesses_on_user_id"
    t.index ["verified"], name: "index_businesses_on_verified"
  end

  create_table "inquiries", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.bigint "user_id", null: false
    t.string "subject"
    t.text "message", null: false
    t.string "contact_phone"
    t.string "preferred_contact_method"
    t.datetime "preferred_contact_time"
    t.integer "status", default: 0
    t.text "business_response"
    t.datetime "responded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_inquiries_on_business_id"
    t.index ["status"], name: "index_inquiries_on_status"
    t.index ["user_id"], name: "index_inquiries_on_user_id"
  end

  create_table "military_backgrounds", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "military_relationship", null: false
    t.string "branch_of_service"
    t.string "rank"
    t.string "mos_specialty"
    t.date "service_start_date"
    t.date "service_end_date"
    t.text "additional_info"
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["military_relationship"], name: "index_military_backgrounds_on_military_relationship"
    t.index ["user_id"], name: "index_military_backgrounds_on_user_id", unique: true
    t.index ["verified"], name: "index_military_backgrounds_on_verified"
  end

  create_table "real_estate_agents", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "brokerage_name", null: false
    t.string "broker_email"
    t.string "brokerage_phone"
    t.string "brokerage_license_number"
    t.text "specialties"
    t.json "certifications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_real_estate_agents_on_business_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.bigint "user_id", null: false
    t.integer "rating", null: false
    t.text "review_text"
    t.string "review_title"
    t.boolean "verified_purchase", default: false
    t.boolean "active", default: true
    t.string "external_source"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_reviews_on_active"
    t.index ["business_id", "user_id"], name: "index_reviews_on_business_and_user", unique: true
    t.index ["business_id"], name: "index_reviews_on_business_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.integer "role", default: 0
    t.integer "membership_status", default: 0
    t.boolean "active", default: true
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_category_assignments", "business_categories"
  add_foreign_key "business_category_assignments", "businesses"
  add_foreign_key "businesses", "users"
  add_foreign_key "inquiries", "businesses"
  add_foreign_key "inquiries", "users"
  add_foreign_key "military_backgrounds", "users"
  add_foreign_key "real_estate_agents", "businesses"
  add_foreign_key "reviews", "businesses"
  add_foreign_key "reviews", "users"
end
