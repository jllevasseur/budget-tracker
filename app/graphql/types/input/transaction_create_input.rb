# frozen_string_literal: true

module Types
  module Input
    class TransactionCreateInput < Types::BaseInputObject
      argument :amount, Float, required: true
      argument :transaction_date, GraphQL::Types::ISO8601Date, required: true
      argument :expense_category_id, ID, required: true
      argument :description, String, required: false
      argument :transaction_type, String, required: false
      argument :budget_id, ID, required: true
    end
  end
end
