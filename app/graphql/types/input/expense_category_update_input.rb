# frozen_string_literal: true

module Types
  module Input
    class ExpenseCategoryUpdateInput < Types::BaseInputObject
      argument :name, String, required: true
      argument :estimated_monthly_expense, Float, required: false
    end
  end
end
