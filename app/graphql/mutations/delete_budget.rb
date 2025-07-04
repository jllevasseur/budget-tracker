# frozen_string_literal: true

module Mutations
  class DeleteBudget < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      budget = current_user.budgets.find_by(id: id)
      return failure_response('Budget not found') unless budget

      if budget.destroy
        { success: true, errors: [] }
      else
        failure_response(budget.errors.full_messages)
      end
    end

    private

    def failure_response(errors)
      { success: false, errors: Array(errors) }
    end
  end
end
