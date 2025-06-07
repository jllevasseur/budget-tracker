# frozen_string_literal: true

class CreateBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :budgets do |t|
      t.string :name, null: false
      t.integer :year, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :budgets, [:user_id, :year], unique: true
  end
end
