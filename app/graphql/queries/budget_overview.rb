# frozen_string_literal: true

module Queries
  class BudgetOverview < Queries::BaseQuery
    argument :id, ID, required: true

    type Types::BudgetOverviewType, null: false

    def resolve(id:)
      user = current_user
      budget = user.budgets.find_by(id: id)
      raise GraphQL::ExecutionError, "Budget not found or access denied" unless budget

      build_budget_overview(budget)
    end

    private

    def build_budget_overview(budget)
      year = budget.year

      # Categories
      categories = budget.categories.map do |category|
        transactions = category.transactions.where('extract(year from transaction_date) = ?', year)
        monthly_expenses = Array.new(12, 0.0)

        transactions.group_by { |t| t.transaction_date.month }.each do |month, trans|
          monthly_expenses[month - 1] = trans.sum(&:amount)
        end

        {
          name: category.name,
          estimated_monthly_expense: category.estimated_monthly_expense,
          monthly_expenses: monthly_expenses,
          year_to_date_total: monthly_expenses.sum
        }
      end

      # Income
      income = budget.incomes.where('extract(year from transaction_date) = ?', year)
      income_by_month = Array.new(12, 0.0)
      income.group_by { |i| i.transaction_date.month }.each do |month, entries|
        income_by_month[month - 1] = entries.sum(&:amount)
      end
      total_income = income_by_month.sum

      # Monthly total expenses
      monthly_expense_totals = Array.new(12, 0.0)
      categories.each do |cat|
        cat[:monthly_expenses].each_with_index do |val, i|
          monthly_expense_totals[i] += val
        end
      end

      # Balances = income - expense
      balance_by_month = income_by_month.each_with_index.map do |income_amt, i|
        income_amt - monthly_expense_totals[i]
      end

      total_expenses = monthly_expense_totals.sum
      total_balance = total_income - total_expenses

      {
        budget_name: budget.name,
        year: year,
        categories: categories,
        income_by_month: income_by_month,
        total_income: total_income,
        balance_by_month: balance_by_month,
        total_balance: total_balance
      }
    end
  end
end
