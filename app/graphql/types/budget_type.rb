# frozen_string_literal: true

module Types
  class BudgetType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :year, Integer, null: false
    field :user, Types::UserType, null: false
    field :categories, [Types::ExpenseCategoryType], null: true
    field :incomes, [Types::IncomeType], null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
