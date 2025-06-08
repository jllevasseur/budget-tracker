# frozen_string_literal: true

module Queries
  class BudgetOverview < Queries::BaseQuery
    argument :id, ID, required: true

    type Types::BudgetOverviewType, null: false

    def resolve(id:)
      user = current_user
      budget = user.budgets
                   .includes(categories: :transactions, incomes: [])
                   .find_by(id: id)

      raise GraphQL::ExecutionError, 'Budget not found or access denied' unless budget

      build_budget_overview(budget)
    end

    private

    def build_budget_overview(budget)
      year = budget.year

      category_transactions_by_month = {}
      budget.categories.includes(:transactions).each do |category|
        category_transactions_by_month[category.id] = category.transactions
                                                              .where('extract(year from transaction_date) = ?', year)
                                                              .group_by { |t| t.transaction_date.month }
      end

      income_by_month = Array.new(12, 0.0)
      budget.incomes.where('extract(year from transaction_date) = ?', year).group_by do |i|
        i.transaction_date.month
      end.each do |month, entries|
        income_by_month[month - 1] = entries.sum(&:amount)
      end

      categories = budget.categories.map do |category|
        monthly_expenses = Array.new(12, 0.0)
        transactions_grouped = category_transactions_by_month[category.id] || {}

        transactions_grouped.each do |month, transactions|
          monthly_expenses[month - 1] = transactions.sum(&:amount)
        end

        {
          name: category.name,
          estimated_monthly_expense: category.estimated_monthly_expense,
          monthly_expenses: monthly_expenses,
          year_to_date_total: monthly_expenses.sum
        }
      end

      total_income = income_by_month.sum

      monthly_expense_totals = Array.new(12, 0.0)
      categories.each do |cat|
        cat[:monthly_expenses].each_with_index do |val, i|
          monthly_expense_totals[i] += val
        end
      end

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
