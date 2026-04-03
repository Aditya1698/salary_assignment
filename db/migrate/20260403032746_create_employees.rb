class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string  :name,        null: false
      t.string  :email,       null: false
      t.string  :department,  null: false
      t.decimal :base_salary, null: false, precision: 10, scale: 2
      t.boolean :active,      null: false, default: true
      t.timestamps
    end

    add_index :employees, :email,      unique: true
    add_index :employees, :department
    add_index :employees, :active
  end
end