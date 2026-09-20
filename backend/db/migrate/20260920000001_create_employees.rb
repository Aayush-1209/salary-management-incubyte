class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string  :employee_number, null: false
      t.string  :email,           null: false
      t.string  :first_name,      null: false
      t.string  :last_name,       null: false
      t.string  :country,         null: false
      t.string  :department,      null: false
      t.string  :job_title,       null: false
      t.string  :level
      t.string  :currency,        null: false, default: "USD"
      t.date    :hired_on,        null: false
      t.boolean :active,          null: false, default: true

      t.timestamps
    end

    add_index :employees, :employee_number, unique: true
    add_index :employees, :email,           unique: true
    add_index :employees, :country
    add_index :employees, :department
    add_index :employees, :active
  end
end
