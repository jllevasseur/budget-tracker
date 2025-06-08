# frozen_string_literal: true

class Mutations::CreateTransaction < Mutations::BaseMutation
  argument :params, Types::Input::TransactionCreateInput, required: true

  field :transaction, Types::TransactionType, null: true
  field :errors, [String], null: false

  def resolve(params:)
    attributes = params.to_h
    attributes[:transaction_type] = attributes[:transaction_type].downcase
    budget_id = attributes.delete(:budget_id)
    expense_category_id = attributes.delete(:expense_category_id)

    budget = current_user.budgets.find_by(id: budget_id)
    return failure_response('Budget not found or unauthorized') unless budget

    expense_category = budget.categories.find_by(id: expense_category_id)
    return failure_response('Expense category not found') unless expense_category

    transaction_date = attributes[:transaction_date]
    if transaction_date.nil? || transaction_date.year != budget.year
      return failure_response("Transaction date must be within the budget year #{budget.year}")
    end

    transaction = expense_category.transactions.new(attributes)

    if transaction.save
      { transaction: transaction, errors: [] }
    else
      { transaction: nil, errors: transaction.errors.full_messages }
    end
  end

  private

  def failure_response(message)
    { transaction: nil, errors: Array(message) }
  end
end
