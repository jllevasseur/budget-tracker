# frozen_string_literal: true

module Types
  module Input
    class IncomeUpdateInput < Types::BaseInputObject
      argument :amount, Float, required: true
      argument :transaction_date, GraphQL::Types::ISO8601Date, required: true
      argument :description, String, required: false
    end
  end
end
