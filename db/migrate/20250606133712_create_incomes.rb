# frozen_string_literal: true

class CreateIncomes < ActiveRecord::Migration[7.1]
  def change
    create_table :incomes do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :transaction_date, null: false
      t.text :description
      t.references :budget, null: false, foreign_key: true

      t.timestamps
    end
  end
end
