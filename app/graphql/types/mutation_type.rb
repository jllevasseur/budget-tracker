# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_budget, mutation: Mutations::CreateBudget
    field :update_budget, mutation: Mutations::UpdateBudget
    field :delete_budget, mutation: Mutations::DeleteBudget

    field :create_expense_category, mutation: Mutations::CreateExpenseCategory
    field :update_expense_category, mutation: Mutations::UpdateExpenseCategory
    field :delete_expense_category, mutation: Mutations::DeleteExpenseCategory
  end
end
