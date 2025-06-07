# typed: false
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpdateExpenseCategory do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, user: user)}
  let!(:expense_category) {
    create(:expense_category, name: 'Home', estimated_monthly_expense: 2000, budget: budget)
  }
  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        id: expense_category.id,
        params: {
          name: 'House',
          estimatedMonthlyExpense: 2500,
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
    mutation updateExpenseCategory($input: UpdateExpenseCategoryInput!) {
      updateExpenseCategory(input: $input) {
        expenseCategory {
            id
            name
            estimatedMonthlyExpense
            budgetId
          }
        errors
      }
    }
    GRAPHQL
  end

  def category_data(result)
      result[:data][:updateExpenseCategory][:expenseCategory]
  end

  def errors_data(result)
    result[:data][:updateExpenseCategory][:errors]
  end

  context "Given a user" do
    it "should update the expense category with no errors" do
      result = nil
      expect do
        result = subject
      end.to change(Budget, :count).by(0)
      .and change(ExpenseCategory, :count).by(0)

      expense_category = category_data(result)
      errors = errors_data(result)

      expect(expense_category[:name]).to eq('House')
      expect(expense_category[:estimatedMonthlyExpense]).to eq(2500)

      expect(errors).to be_empty

    end
  end

  context "Errors" do
    context "Given another user" do
      let(:context) { { current_user: create(:user) } }

      it "should not update the expense category with error" do
        result = subject

        expense_category = category_data(result)
        errors = errors_data(result)

        expect(expense_category).to eq(nil)
        expect(errors).to eq(["Unauthorized"])
      end
    end

    context "Given an expense category not belonging to the user" do
      let(:existing_budget) { create(:budget, :with_categories, user: create(:user)) }
      let(:existing_expense_category) {
        create(:expense_category, name: 'Home', estimated_monthly_expense: 2000, budget: existing_budget)
      }
      before { variables[:input][:id] = existing_expense_category.id }

      it "should not create the budget with error" do
        result = subject

        expense_category = category_data(result)
        errors = errors_data(result)

        expect(expense_category).to eq(nil)
        expect(errors).to eq(["Unauthorized"])
      end
    end
    context "Given no user is logged in" do
      let(:context) { { current_user: nil } }
      it_behaves_like "requires authentication"
    end
  end
end
