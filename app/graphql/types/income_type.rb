# frozen_string_literal: true

module Types
  class IncomeType < Types::BaseObject
    field :id, ID, null: false
    field :amount, Float, null: false
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :description, String, null: true
    field :budget, Types::BudgetType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
