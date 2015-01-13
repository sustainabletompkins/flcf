# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150113054154) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "game_stats", force: true do |t|
    t.float   "avg"
    t.integer "total"
    t.integer "plays"
    t.integer "user_id"
    t.integer "game_id"
  end

  create_table "games", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "logo_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "avg"
    t.integer  "plays",          default: 0
    t.integer  "game_num",       default: 1
    t.float    "expected_score"
  end

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "offsets", force: true do |t|
    t.integer "user_id"
    t.string  "title"
    t.float   "pounds"
    t.float   "cost"
    t.string  "units"
    t.float   "quantity"
    t.boolean "purchased", default: false
  end

  create_table "rankings", force: true do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.float   "score"
    t.float   "percentile"
  end

  create_table "scores", force: true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "game_num"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value",      default: 0
  end

  create_table "spot_values", force: true do |t|
    t.integer "value"
  end

  create_table "streaks", force: true do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.integer "streak",    default: 0
    t.string  "direction"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",  null: false
    t.string   "encrypted_password",     default: "",  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "username"
    t.string   "about"
    t.float    "score",                  default: 0.0
    t.float    "percentile",             default: 0.0
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
