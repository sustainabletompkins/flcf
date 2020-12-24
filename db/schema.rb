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

ActiveRecord::Schema.define(version: 2020_12_24_223209) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awardees", force: :cascade do |t|
    t.string "name"
    t.text "bio"
    t.string "video_id"
    t.string "img_url"
    t.integer "award_amount"
    t.integer "pounds_offset"
    t.datetime "award_date"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "identities", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "individuals", force: :cascade do |t|
    t.string "name"
    t.integer "pounds"
    t.integer "count"
    t.string "email"
  end

  create_table "offsets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.float "pounds"
    t.float "cost"
    t.string "units"
    t.float "quantity"
    t.boolean "purchased", default: false
    t.string "session_id"
    t.string "name"
    t.integer "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email"
    t.integer "team_id", default: 0
    t.integer "individual_id", default: 0
    t.index ["user_id"], name: "index_offsets_on_user_id"
  end

  create_table "offsetters", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "pages", force: :cascade do |t|
    t.text "body"
    t.string "title"
    t.boolean "published"
    t.boolean "menu"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slug"
  end

  create_table "prize_winners", force: :cascade do |t|
    t.string "email"
    t.bigint "prize_id"
    t.string "code"
    t.boolean "claimed", default: false
    t.string "name", default: "Anonymous"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prize_id"], name: "index_prize_winners_on_prize_id"
  end

  create_table "prizes", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "count"
    t.datetime "expiration_date"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string "key", limit: 40
    t.string "value", limit: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "idx_key"
  end

  create_table "stats", force: :cascade do |t|
    t.integer "pounds"
    t.float "dollars"
    t.integer "offsets"
    t.integer "awardees"
    t.integer "wheel_spins", default: 0
  end

  create_table "team_members", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.integer "offsets"
    t.integer "team_id"
    t.boolean "founder"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.integer "members"
    t.integer "pounds", default: 0
    t.integer "count"
    t.float "participation_rate"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name"
    t.string "username"
    t.string "about"
    t.string "session_id"
    t.string "name"
    t.integer "zipcode"
    t.string "api_secret"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
