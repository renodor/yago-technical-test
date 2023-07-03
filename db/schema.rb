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

ActiveRecord::Schema[7.0].define(version: 2023_06_29_165809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "leads", force: :cascade do |t|
    t.string "email", null: false
    t.string "phone_number", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "address_2"
    t.string "zip_code"
    t.string "city"
    t.string "nacebel_codes", default: [], array: true
    t.integer "activity", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.integer "annual_revenue", null: false
    t.string "enterprise_number", null: false
    t.string "legal_name"
    t.boolean "natural_person", default: true, null: false
    t.integer "coverage_ceiling"
    t.integer "deductible"
    t.jsonb "covers", default: {}
    t.bigint "lead_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_quotes_on_lead_id"
  end

  add_foreign_key "quotes", "leads"
end
