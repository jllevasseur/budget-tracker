# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.1]
  def up
    create_table :transactions do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :transaction_date, null: false
      t.references :expense_category, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end

    execute <<-SQL
      CREATE TYPE transaction_types AS ENUM ('expense', 'refund');
    SQL

    add_column :transactions, :transaction_type, :transaction_types, null: false, default: 'expense'
  end

  def down
    remove_column :transactions, :transaction_type

    drop_table :transactions

    execute <<-SQL
      DROP TYPE transaction_types;
    SQL
  end
end
