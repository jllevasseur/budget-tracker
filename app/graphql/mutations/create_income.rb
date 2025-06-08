# frozen_string_literal: true

class Mutations::CreateIncome < Mutations::BaseMutation
  argument :params, Types::Input::IncomeCreateInput, required: true

  field :income, Types::IncomeType, null: true
  field :errors, [String], null: false

  def resolve(params:)
    attributes = params.to_h
    budget_id = attributes.delete(:budget_id)

    budget = current_user.budgets.find_by(id: budget_id)
    return failure_response('Budget not found or unauthorized') unless budget

    transaction_date = attributes[:transaction_date]
    if transaction_date.nil? || transaction_date.year != budget.year
      return failure_response("Transaction date must be within the budget year #{budget.year}")
    end

    income = budget.incomes.new(attributes)

    if income.save
      { income: income, errors: [] }
    else
      { income: nil, errors: income.errors.full_messages }
    end
  end

  private

  def failure_response(message)
    { income: nil, errors: Array(message) }
  end
end
