# frozen_string_literal: true

module Mutations
  class UpdateExpenseCategory < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :params, Types::Input::ExpenseCategoryUpdateInput, required: true

    field :expense_category, Types::ExpenseCategoryType, null: true
    field :errors, [String], null: false

    def resolve(id:, params:)
      attributes = params.to_h
      user = current_user

      expense_category = ExpenseCategory.find_by(id: id)
      return { expense_category: nil, errors: ["Expense category not found"] } unless expense_category

      budget = expense_category.budget
      return { expense_category: nil, errors: ["Unauthorized"] } unless budget&.user == user

      if budget.categories
          .where('LOWER(name) = ?', attributes[:name].downcase)
          .where.not(id: expense_category.id)
          .exists?
        return { expense_category: nil, errors: ["Expense category already exists for this budget"] }
      end

      if expense_category.update(attributes)
        { expense_category: expense_category, errors: [] }
      else
        { expense_category: nil, errors: expense_category.errors.full_messages }
      end
    end
  end
end
