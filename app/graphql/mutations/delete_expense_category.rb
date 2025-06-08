# frozen_string_literal: true

module Mutations
  class DeleteExpenseCategory < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      expense_category = ExpenseCategory.find_by(id: id)
      return failure_response('Expense category not found') unless expense_category

      return failure_response('Unauthorized') unless expense_category.budget&.user == current_user

      if expense_category.destroy
        { success: true, errors: [] }
      else
        failure_response(expense_category.errors.full_messages)
      end
    end

    private

    def failure_response(errors)
      { success: false, errors: Array(errors) }
    end
  end
end
