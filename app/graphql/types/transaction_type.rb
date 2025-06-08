# frozen_string_literal: true

module Types
  class TransactionType < Types::BaseObject
    field :id, ID, null: false
    field :amount, Float, null: false
    field :transaction_date, GraphQL::Types::ISO8601Date, null: false
    field :transaction_type, String, null: false
    field :description, String, null: true
    field :expense_category, Types::ExpenseCategoryType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end

  def amount
    object.amount.to_f
  end
end
