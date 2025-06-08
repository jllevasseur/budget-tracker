# frozen_string_literal: true

class Mutations::CreateExpenseCategory < Mutations::BaseMutation
  argument :params, Types::Input::ExpenseCategoryCreateInput, required: true

  field :expense_category, Types::ExpenseCategoryType, null: true
  field :errors, [String], null: false

  def resolve(params:)
    attributes = params.to_h
    budget_id = attributes.delete(:budget_id)

    budget = current_user.budgets.find_by(id: budget_id)
    return failure_response('Budget not found') unless budget

    if budget.categories.where('LOWER(name) = ?', attributes[:name].downcase).exists?
      return failure_response('Expense category already exists for this budget')
    end

    expense_category = budget.categories.new(attributes)

    if expense_category.save
      { expense_category: expense_category, errors: [] }
    else
      { expense_category: nil, errors: expense_category.errors.full_messages }
    end
  end

  private

  def failure_response(message)
    { expense_category: nil, errors: Array(message) }
  end
end
