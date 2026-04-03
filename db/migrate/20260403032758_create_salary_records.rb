class CreateSalaryRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :salary_records do |t|
      t.references :employee,    null: false, foreign_key: true
      t.decimal    :base_salary, null: false, precision: 10, scale: 2
      t.decimal    :bonus,       null: false, precision: 10, scale: 2, default: "0"
      t.decimal    :deductions,  null: false, precision: 10, scale: 2, default: "0"
      t.integer    :month,       null: false
      t.integer    :year,        null: false
      t.timestamps
    end

    add_index :salary_records, %i[employee_id month year], unique: true,
              name: "index_salary_records_on_employee_month_year"
  end
end