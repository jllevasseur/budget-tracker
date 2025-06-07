# frozen_string_literal: true

module Mutations
  class UpdateBudget < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :params, Types::Input::BudgetUpdateInput, required: true

    field :budget, Types::BudgetType, null: true
    field :errors, [String], null: false

    def resolve(id:, params:)
      user = current_user

      budget = user.budgets.find_by(id: id)
      return { success: false, errors: ["Budget not found"] } unless budget

      attributes = params.to_h

      if budget.update(attributes)
        { budget: budget, errors: [] }
      else
        { budget: nil, errors: budget.errors.full_messages }
      end
    end
  end
end
