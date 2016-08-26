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

ActiveRecord::Schema.define(version: 201606062308301) do

  create_table "activities", force: :cascade do |t|
    t.integer  "amount",     null: false
    t.integer  "user_id"
    t.integer  "item_id",    null: false
    t.date     "date",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "streaks", force: :cascade do |t|
    t.date     "start",      null: false
    t.date     "end",        null: false
    t.integer  "length",     null: false
    t.integer  "item_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "username",        null: false
    t.string   "hashed_password", null: false
    t.string   "salt",            null: false
    t.string   "preferences",     null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.date     "birthday"
    t.string   "gender"
    t.integer  "height"
  end

  create_table "v1_healthscores", force: :cascade do |t|
    t.integer "date",    null: false
    t.integer "value",   null: false
    t.integer "user_id"
  end

  create_table "v1_items", force: :cascade do |t|
    t.string  "title",                    null: false
    t.string  "filename",                 null: false
    t.integer "health_type",  default: 0, null: false
    t.integer "item_type_id"
  end

  create_table "v1_streaks", force: :cascade do |t|
    t.integer "start",   null: false
    t.integer "end",     null: false
    t.integer "length",  null: false
    t.integer "user_id"
    t.integer "item_id"
  end

  create_table "v1_user_items", force: :cascade do |t|
    t.integer "date",                             null: false
    t.decimal "count",   precision: 10, scale: 2, null: false
    t.integer "item_id"
    t.integer "user_id"
  end

  create_table "v1_user_preferences", force: :cascade do |t|
    t.string  "name",    null: false
    t.string  "value",   null: false
    t.integer "user_id"
  end

  create_table "v1_users", force: :cascade do |t|
    t.text     "name",            null: false
    t.text     "username",        null: false
    t.text     "hashed_password", null: false
    t.text     "salt",            null: false
    t.datetime "last_login",      null: false
    t.datetime "created_login",   null: false
    t.integer  "temp",            null: false
    t.text     "phone_num"
  end

end
