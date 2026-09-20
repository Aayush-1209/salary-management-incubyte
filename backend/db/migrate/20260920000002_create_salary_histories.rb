class CreateSalaryHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :salary_histories do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :gross_salary,  null: false, precision: 15, scale: 2
      t.date    :effective_date, null: false
      t.string  :reason
      t.text    :notes

      t.timestamps
    end

    add_index :salary_histories, :effective_date
    add_index :salary_histories, %i[employee_id effective_date],
              name: "index_salary_histories_on_employee_and_date"
  end
end
