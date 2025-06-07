# frozen_string_literal: true

module Types
  class ExpenseCategoryType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :estimated_monthly_expense, Float, null: false
    field :budget_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end

  def estimated_monthly_expense
    object.estimated_monthly_expense.to_f
  end
end
