# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::BudgetOverview do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, user: user, year: 2025) }
  let(:category) { create(:expense_category, budget: budget, estimated_monthly_expense: 100) }

  let!(:expenses) do
    (1..3).map do |month|
      create(:transaction, expense_category: category, amount: 100.0, transaction_date: Date.new(2025, month, 15))
    end
  end

  let!(:incomes) do
    (1..3).map do |month|
      create(:income, amount: 2000.0, budget: budget, transaction_date: Date.new(2025, month, 15))
    end
  end

  let(:context) { { current_user: user } }

  let(:variables) { { id: budget.id } }

  let(:query_string) do
    <<~GRAPHQL
      query budgetOverview($id: ID!) {
        budgetOverview(id: $id) {
           budgetName
          year
          totalIncome
          totalBalance
          incomeByMonth
          balanceByMonth
          categories {
            name
            estimatedMonthlyExpense
            monthlyExpenses
            yearToDateTotal
          }
        }
      }
    GRAPHQL
  end

  context 'Given a budget with categories, expenses and income' do
    it 'returns the correct budget overview' do
      result = subject

      data = result[:data][:budgetOverview]

      expect(data[:year]).to eq(2025)
      expect(data[:categories].first[:name]).to eq(category.name)
      expect(data[:categories].first[:monthlyExpenses][0]).to eq(100.0)
      expect(data[:categories].first[:yearToDateTotal]).to eq(300.0)
      expect(data[:totalIncome]).to eq(6000.0)
      expect(data[:incomeByMonth][0]).to eq(2000.0)
    end
  end
  context 'Errors' do
    context 'authorization' do
      it_behaves_like 'requires authentication'
    end
    context 'When accessing a budget not owned by the user' do
      let(:context) { create(:user) }
      it 'returns an Unauthorized error when user is not the owner' do
        result = execute_graphql_query(
          query_string: query_string,
          context: { current_user: create(:user) },
          variables: defined?(variables) ? variables : {},
          expect_errors: true
        )

        expect(result).to include(
          errors: [hash_including(message: 'Budget not found or unauthorized')]
        )
      end
    end
  end
end
