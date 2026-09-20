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

ActiveRecord::Schema[7.2].define(version: 2026_09_20_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "employee_number", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "country", null: false
    t.string "department", null: false
    t.string "job_title", null: false
    t.string "level"
    t.string "currency", default: "USD", null: false
    t.date "hired_on", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_employees_on_active"
    t.index ["country"], name: "index_employees_on_country"
    t.index ["department"], name: "index_employees_on_department"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_number"], name: "index_employees_on_employee_number", unique: true
  end

  create_table "salary_histories", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.decimal "gross_salary", precision: 15, scale: 2, null: false
    t.date "effective_date", null: false
    t.string "reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effective_date"], name: "index_salary_histories_on_effective_date"
    t.index ["employee_id", "effective_date"], name: "index_salary_histories_on_employee_and_date"
    t.index ["employee_id"], name: "index_salary_histories_on_employee_id"
  end

  add_foreign_key "salary_histories", "employees"
end
