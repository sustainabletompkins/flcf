# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_25_200858) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awardees", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "bio"
    t.string "video_id", limit: 255
    t.string "img_url", limit: 255
    t.integer "award_amount"
    t.integer "pounds_offset"
    t.datetime "award_date"
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.bigint "region_id"
    t.index ["region_id"], name: "index_awardees_on_region_id"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "individuals", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "pounds"
    t.integer "count"
    t.string "email", limit: 255
    t.bigint "region_id"
    t.index ["region_id"], name: "index_individuals_on_region_id"
  end

  create_table "offsets", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title", limit: 255
    t.float "pounds"
    t.float "cost"
    t.string "units", limit: 255
    t.float "quantity"
    t.boolean "purchased", default: false
    t.string "session_id", limit: 255
    t.string "name", limit: 255
    t.integer "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 255
    t.integer "team_id", default: 0
    t.integer "individual_id", default: 0
    t.bigint "region_id"
    t.index ["region_id"], name: "index_offsets_on_region_id"
  end

  create_table "offsetters", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.text "body"
    t.string "title", limit: 255
    t.boolean "published"
    t.boolean "menu"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "slug"
  end

  create_table "prize_winners", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.integer "prize_id"
    t.string "code", limit: 255
    t.boolean "claimed", default: false
    t.string "name", limit: 255, default: "Anonymous"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prizes", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "description", limit: 255
    t.integer "count"
    t.datetime "expiration_date"
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.bigint "region_id"
    t.index ["region_id"], name: "index_prizes_on_region_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.string "counties"
    t.text "zipcodes", default: [], array: true
  end

  create_table "simple_captcha_data", id: :serial, force: :cascade do |t|
    t.string "key", limit: 40
    t.string "value", limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "idx_key"
  end

  create_table "stats", id: :serial, force: :cascade do |t|
    t.integer "pounds"
    t.float "dollars"
    t.integer "offsets"
    t.integer "awardees"
    t.integer "wheel_spins", default: 0
  end

  create_table "team_members", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "name", limit: 255
    t.integer "offsets"
    t.integer "team_id"
    t.boolean "founder"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "members"
    t.integer "pounds", default: 0
    t.integer "count"
    t.float "participation_rate"
    t.bigint "region_id"
    t.index ["region_id"], name: "index_teams_on_region_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "first_name", limit: 255
    t.string "username", limit: 255
    t.string "about", limit: 255
    t.string "session_id", limit: 255
    t.string "name", limit: 255
    t.integer "zipcode"
    t.string "api_secret"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "awardees", "regions"
  add_foreign_key "individuals", "regions"
  add_foreign_key "offsets", "regions"
  add_foreign_key "prizes", "regions"
  add_foreign_key "teams", "regions"
end
