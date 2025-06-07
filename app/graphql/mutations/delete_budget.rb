# frozen_string_literal: true

module Mutations
  class DeleteBudget < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      user = current_user

      budget = user.budgets.find_by(id: id)
      return { success: false, errors: ["Budget not found"] } unless budget

      if budget.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: budget.errors.full_messages }
      end
    end
  end
end
