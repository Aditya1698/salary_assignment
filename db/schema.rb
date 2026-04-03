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

ActiveRecord::Schema[7.2].define(version: 2026_04_03_032758) do
  create_table "employees", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "department", null: false
    t.decimal "base_salary", precision: 10, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_employees_on_active"
    t.index ["department"], name: "index_employees_on_department"
    t.index ["email"], name: "index_employees_on_email", unique: true
  end

  create_table "salary_records", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.decimal "base_salary", precision: 10, scale: 2, null: false
    t.decimal "bonus", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "deductions", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "month", "year"], name: "index_salary_records_on_employee_month_year", unique: true
    t.index ["employee_id"], name: "index_salary_records_on_employee_id"
  end

  add_foreign_key "salary_records", "employees"
end
