# frozen_string_literal: true

module Mutations
  class DeleteTransaction < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      transaction = Transaction.find_by(id: id)
      return failure_response('Expense category not found') unless transaction

      return failure_response('Unauthorized') unless transaction.expense_category.budget&.user == current_user

      if transaction.destroy
        { success: true, errors: [] }
      else
        failure_response(transaction.errors.full_messages)
      end
    end

    private

    def failure_response(errors)
      { success: false, errors: Array(errors) }
    end
  end
end
