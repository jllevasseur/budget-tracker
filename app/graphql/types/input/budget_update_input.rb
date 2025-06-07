# frozen_string_literal: true

module Types
  module Input
    class BudgetUpdateInput < Types::BaseInputObject
      argument :name, String, required: false
      argument :year, Integer, required: false
    end
  end
end
