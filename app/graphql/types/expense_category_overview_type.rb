# frozen_string_literal: true

module Types
  class ExpenseCategoryOverviewType < Types::BaseObject
    field :name, String, null: false
    field :estimated_monthly_expense, Float, null: true
    field :monthly_expenses, [Float], null: false
    field :year_to_date_total, Float, null: false
  end

  def estimated_monthly_expense
    object.estimated_monthly_expense.to_f
  end
end
