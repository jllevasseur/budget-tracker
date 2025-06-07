# frozen_string_literal: true

module Types
  module Input
    class BudgetCreateInput < Types::BaseInputObject
      argument :name, String, required: true
      argument :user_id, ID, required: true
      argument :year, Integer, required: true
      argument :duplicate_from_budget_id, ID, required: false
    end
  end
end
