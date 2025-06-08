# frozen_string_literal: true

module Mutations
  class UpdateIncome < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :params, Types::Input::IncomeUpdateInput, required: true

    field :income, Types::IncomeType, null: true
    field :errors, [String], null: false

    def resolve(id:, params:)
      user = current_user
      attributes = params.to_h

      income = Income.find_by(id: id)
      return failure_response(['Income not found']) unless income

      budget = income.budget
      return failure_response(['Unauthorized']) unless budget&.user == user

      transaction_date = attributes[:transaction_date]
      if transaction_date.nil? || transaction_date.year != budget.year
        return failure_response("Transaction date must be within the budget year #{budget.year}")
      end

      return { income: income, errors: [] } if income.update(attributes)

      failure_response(income.errors.full_messages)
    end

    private

    def failure_response(errors)
      { income: nil, errors: Array(errors) }
    end
  end
end
