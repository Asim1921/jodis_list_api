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

ActiveRecord::Schema[8.0].define(version: 2025_06_28_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "cube"
  enable_extension "earthdistance"
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

  create_table "business_analytics", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.date "date"
    t.integer "page_views", default: 0
    t.integer "profile_views", default: 0
    t.integer "phone_clicks", default: 0
    t.integer "email_clicks", default: 0
    t.integer "website_clicks", default: 0
    t.integer "direction_requests", default: 0
    t.integer "inquiry_submissions", default: 0
    t.integer "review_submissions", default: 0
    t.json "traffic_sources"
    t.json "search_keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "date"], name: "index_business_analytics_on_business_id_and_date", unique: true
    t.index ["business_id"], name: "index_business_analytics_on_business_id"
    t.index ["date"], name: "index_business_analytics_on_date"
    t.index ["page_views"], name: "index_business_analytics_on_page_views"
  end

  create_table "business_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "icon_class"
    t.boolean "active", default: true
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.integer "level", default: 0
    t.boolean "requires_license", default: false
    t.boolean "emergency_service", default: false
    t.string "keywords", default: [], array: true
    t.string "image_url"
    t.string "color_code"
    t.string "slug"
    t.string "meta_title"
    t.text "meta_description"
    t.index ["active"], name: "index_business_categories_on_active"
    t.index ["emergency_service"], name: "index_business_categories_on_emergency_service"
    t.index ["keywords"], name: "index_business_categories_on_keywords", using: :gin
    t.index ["level"], name: "index_business_categories_on_level"
    t.index ["name"], name: "index_business_categories_on_name", unique: true
    t.index ["parent_id"], name: "index_business_categories_on_parent_id"
    t.index ["requires_license"], name: "index_business_categories_on_requires_license"
    t.index ["slug"], name: "index_business_categories_on_slug", unique: true
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

  create_table "business_hours", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.integer "day_of_week"
    t.time "open_time"
    t.time "close_time"
    t.boolean "closed", default: false
    t.boolean "open_24_hours", default: false
    t.text "special_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "day_of_week"], name: "index_business_hours_on_business_id_and_day_of_week", unique: true
    t.index ["business_id"], name: "index_business_hours_on_business_id"
    t.index ["day_of_week"], name: "index_business_hours_on_day_of_week"
  end

  create_table "business_specialties", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "specialty_name", null: false
    t.text "description"
    t.decimal "price_range_min", precision: 10, scale: 2
    t.decimal "price_range_max", precision: 10, scale: 2
    t.string "price_unit"
    t.boolean "featured", default: false
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "featured"], name: "index_business_specialties_on_business_id_and_featured"
    t.index ["business_id"], name: "index_business_specialties_on_business_id"
    t.index ["sort_order"], name: "index_business_specialties_on_sort_order"
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
    t.integer "years_in_business"
    t.integer "employee_count"
    t.boolean "emergency_service", default: false
    t.boolean "insured", default: false
    t.boolean "bonded", default: false
    t.boolean "background_checked", default: false
    t.text "services_offered"
    t.string "payment_methods", default: [], array: true
    t.string "languages_spoken", default: [], array: true
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "suspended_at"
    t.datetime "featured_at"
    t.text "rejection_reason"
    t.text "suspension_reason"
    t.text "admin_notes"
    t.integer "verification_status", default: 0
    t.boolean "verification_documents_required", default: false
    t.text "verification_notes"
    t.datetime "last_verification_date"
    t.string "keywords", default: [], array: true
    t.json "social_media_links"
    t.text "promotional_message"
    t.json "special_offers"
    t.integer "view_count", default: 0
    t.integer "inquiry_count", default: 0
    t.datetime "last_activity_at"
    t.index ["approved_at"], name: "index_businesses_on_approved_at"
    t.index ["bonded"], name: "index_businesses_on_bonded"
    t.index ["business_status", "featured", "verified"], name: "index_businesses_on_business_status_and_featured_and_verified"
    t.index ["business_status"], name: "index_businesses_on_business_status"
    t.index ["emergency_service", "insured", "business_status"], name: "idx_on_emergency_service_insured_business_status_a5caddf8ab"
    t.index ["emergency_service"], name: "index_businesses_on_emergency_service"
    t.index ["employee_count"], name: "index_businesses_on_employee_count"
    t.index ["featured"], name: "index_businesses_on_featured"
    t.index ["inquiry_count"], name: "index_businesses_on_inquiry_count"
    t.index ["insured"], name: "index_businesses_on_insured"
    t.index ["keywords"], name: "index_businesses_on_keywords", using: :gin
    t.index ["languages_spoken"], name: "index_businesses_on_languages_spoken", using: :gin
    t.index ["last_activity_at"], name: "index_businesses_on_last_activity_at"
    t.index ["latitude", "longitude"], name: "index_businesses_on_latitude_and_longitude"
    t.index ["payment_methods"], name: "index_businesses_on_payment_methods", using: :gin
    t.index ["slug"], name: "index_businesses_on_slug", unique: true
    t.index ["state", "city", "business_status"], name: "index_businesses_on_state_and_city_and_business_status"
    t.index ["user_id"], name: "index_businesses_on_user_id"
    t.index ["verification_status"], name: "index_businesses_on_verification_status"
    t.index ["verified"], name: "index_businesses_on_verified"
    t.index ["view_count"], name: "index_businesses_on_view_count"
    t.index ["years_in_business"], name: "index_businesses_on_years_in_business"
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
    t.integer "helpful_count", default: 0
    t.boolean "verified_reviewer", default: false
    t.text "response_from_owner"
    t.datetime "owner_response_date"
    t.boolean "photos_attached", default: false
    t.date "service_date"
    t.string "project_cost_range"
    t.boolean "would_recommend"
    t.integer "response_time_rating"
    t.integer "quality_rating"
    t.integer "value_rating"
    t.string "external_platform"
    t.string "external_review_id"
    t.string "external_url"
    t.datetime "last_synced_at"
    t.index ["active"], name: "index_reviews_on_active"
    t.index ["business_id", "user_id"], name: "index_reviews_on_business_and_user", unique: true
    t.index ["business_id"], name: "index_reviews_on_business_id"
    t.index ["external_platform", "external_review_id"], name: "index_reviews_on_external_platform_and_external_review_id", unique: true
    t.index ["helpful_count"], name: "index_reviews_on_helpful_count"
    t.index ["last_synced_at"], name: "index_reviews_on_last_synced_at"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["service_date"], name: "index_reviews_on_service_date"
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.index ["verified_reviewer"], name: "index_reviews_on_verified_reviewer"
    t.index ["would_recommend"], name: "index_reviews_on_would_recommend"
  end

  create_table "saved_searches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "search_name"
    t.json "search_params"
    t.boolean "email_notifications", default: false
    t.integer "notification_frequency", default: 0
    t.datetime "last_notification_sent"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_notifications"], name: "index_saved_searches_on_email_notifications"
    t.index ["user_id", "active"], name: "index_saved_searches_on_user_id_and_active"
    t.index ["user_id"], name: "index_saved_searches_on_user_id"
  end

  create_table "service_areas", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "area_type"
    t.string "area_name"
    t.string "state_code"
    t.string "country_code", default: "US"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "radius_miles"
    t.boolean "primary_area", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_name", "state_code"], name: "index_service_areas_on_area_name_and_state_code"
    t.index ["business_id", "area_type"], name: "index_service_areas_on_business_id_and_area_type"
    t.index ["business_id"], name: "index_service_areas_on_business_id"
    t.index ["latitude", "longitude"], name: "index_service_areas_on_latitude_and_longitude"
    t.index ["primary_area"], name: "index_service_areas_on_primary_area"
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
  add_foreign_key "business_analytics", "businesses"
  add_foreign_key "business_categories", "business_categories", column: "parent_id"
  add_foreign_key "business_category_assignments", "business_categories"
  add_foreign_key "business_category_assignments", "businesses"
  add_foreign_key "business_hours", "businesses"
  add_foreign_key "business_specialties", "businesses"
  add_foreign_key "businesses", "users"
  add_foreign_key "inquiries", "businesses"
  add_foreign_key "inquiries", "users"
  add_foreign_key "military_backgrounds", "users"
  add_foreign_key "real_estate_agents", "businesses"
  add_foreign_key "reviews", "businesses"
  add_foreign_key "reviews", "users"
  add_foreign_key "saved_searches", "users"
  add_foreign_key "service_areas", "businesses"
end
