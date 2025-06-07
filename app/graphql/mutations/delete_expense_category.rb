# frozen_string_literal: true

module Mutations
  class DeleteExpenseCategory < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      user = current_user

      expense_category = ExpenseCategory.find_by(id: id)
      return { success: false, errors: ["Expense category not found"] } unless expense_category

      return { success: false, errors: ["Unauthorized"] } unless expense_category.budget&.user == user

      if expense_category.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: expense_category.errors.full_messages }
      end
    end
  end
end
