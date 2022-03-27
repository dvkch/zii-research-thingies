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

ActiveRecord::Schema.define(version: 2022_03_27_112628) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
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
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "permissions", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "twitter_search_sources", force: :cascade do |t|
    t.bigint "twitter_search_id"
    t.string "query", null: false
    t.boolean "include_replies", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["twitter_search_id"], name: "index_twitter_search_sources_on_twitter_search_id"
  end

  create_table "twitter_searches", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "twitter_tweets", force: :cascade do |t|
    t.bigint "twitter_search_id"
    t.bigint "twitter_search_source_id"
    t.datetime "date", null: false
    t.string "username", null: false
    t.text "content", null: false
    t.string "twitter_id", null: false
    t.integer "retweet_count", default: 0, null: false
    t.integer "like_count", default: 0, null: false
    t.integer "reply_count", default: 0, null: false
    t.integer "quote_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["twitter_search_id"], name: "index_twitter_tweets_on_twitter_search_id"
    t.index ["twitter_search_source_id"], name: "index_twitter_tweets_on_twitter_search_source_id"
  end

end
