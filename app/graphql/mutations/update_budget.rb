# frozen_string_literal: true

module Mutations
  class UpdateBudget < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :params, Types::Input::BudgetUpdateInput, required: true

    field :budget, Types::BudgetType, null: true
    field :errors, [String], null: false

    def resolve(id:, params:)
      budget = current_user.budgets.find_by(id: id)
      return failure_response('Budget not found') unless budget

      attributes = params.to_h

      return { budget: budget, errors: [] } if budget.update(attributes)

      failure_response(budget.errors.full_messages)
    end

    private

    def failure_response(errors)
      { budget: nil, errors: Array(errors) }
    end
  end
end
