# frozen_string_literal: true

module Mutations
  class UpdateExpenseCategory < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :params, Types::Input::ExpenseCategoryUpdateInput, required: true

    field :expense_category, Types::ExpenseCategoryType, null: true
    field :errors, [String], null: false

    def resolve(id:, params:)
      attributes = params.to_h

      expense_category = ExpenseCategory.find_by(id: id)
      return failure_response(['Expense category not found']) unless expense_category

      budget = expense_category.budget
      authorize_owner!(budget)

      if budget.categories
               .where('LOWER(name) = ?', attributes[:name].downcase)
               .where.not(id: expense_category.id)
               .exists?
        return failure_response(['Expense category already exists for this budget'])
      end

      return { expense_category: expense_category, errors: [] } if expense_category.update(attributes)

      failure_response(expense_category.errors.full_messages)
    end

    private

    def failure_response(errors)
      { expense_category: nil, errors: Array(errors) }
    end
  end
end
