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

ActiveRecord::Schema[7.1].define(version: 2025_11_06_093457) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "reviews", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "channel", null: false
    t.integer "rating", null: false
    t.date "review_date", null: false
    t.string "title"
    t.text "description"
    t.string "fingerprint", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_reviews_on_channel"
    t.index ["company_name"], name: "index_reviews_on_company_name"
    t.index ["description"], name: "index_reviews_on_description", opclass: :gist_trgm_ops, using: :gist
    t.index ["fingerprint"], name: "index_reviews_on_fingerprint", unique: true
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["review_date"], name: "index_reviews_on_review_date"
  end

end
