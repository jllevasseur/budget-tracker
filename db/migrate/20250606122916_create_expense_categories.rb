# frozen_string_literal: true

class CreateExpenseCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :expense_categories do |t|
      t.string :name, null: false
      t.decimal :estimated_monthly_expense, precision: 10, scale: 2, default: 0.0, null: true
      t.references :budget, null: false, foreign_key: true

      t.timestamps
    end

    add_index :expense_categories, [:budget_id, :name], unique: true
  end
end
