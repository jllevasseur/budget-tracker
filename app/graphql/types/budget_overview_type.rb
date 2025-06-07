# frozen_string_literal: true

module Types
  class BudgetOverviewType < Types::BaseObject
    field :budget_name, String, null: false
    field :year, Integer, null: false
    field :categories, [Types::ExpenseCategoryOverviewType], null: false
    field :income_by_month, [Float], null: false
    field :total_income, Float, null: false
    field :balance_by_month, [Float], null: false
    field :total_balance, Float, null: false
  end
end
