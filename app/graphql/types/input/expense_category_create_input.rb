# frozen_string_literal: true

module Types
  module Input
    class ExpenseCategoryCreateInput < Types::BaseInputObject
      argument :budget_id, ID, required: true
      argument :name, String, required: true
      argument :estimated_monthly_expense, Float, required: false
    end
  end
end
