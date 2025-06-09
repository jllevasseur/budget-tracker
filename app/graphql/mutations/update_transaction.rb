# frozen_string_literal: true

module Mutations
  class UpdateTransaction < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :params, Types::Input::TransactionUpdateInput, required: true

    field :transaction, Types::TransactionType, null: true
    field :errors, [String], null: false

    def resolve(id:, params:)
      attributes = params.to_h

      transaction = Transaction.find_by(id: id)
      authorize_owner!(transaction&.expense_category&.budget)

      if (new_id = attributes[:expense_category_id]) && new_id != transaction.expense_category_id
        new_category = ExpenseCategory.find_by(id: new_id)
        return failure_response(['Expense category not found']) unless new_category
      end

      transaction_date = attributes[:transaction_date]
      budget = transaction.expense_category.budget

      unless transaction_date&.year == budget.year
        return failure_response("Transaction date must be within the budget year #{budget.year}")
      end

      return { transaction: transaction, errors: [] } if transaction.update(attributes)

      failure_response(transaction.errors.full_messages)
    end

    private

    def failure_response(errors)
      { transaction: nil, errors: Array(errors) }
    end
  end
end
