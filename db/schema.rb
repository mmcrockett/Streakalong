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

ActiveRecord::Schema[8.1].define(version: 2026_08_19_132427) do
  create_table "activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "item_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "streaks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at"
    t.date "end", null: false
    t.integer "item_id", null: false
    t.integer "length", null: false
    t.date "start", null: false
    t.datetime "updated_at"
    t.integer "user_id", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "birthday"
    t.datetime "created_at", null: false
    t.string "gender"
    t.string "hashed_password", null: false
    t.integer "height"
    t.string "name", null: false
    t.string "preferences", null: false
    t.string "salt", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
  end
end
