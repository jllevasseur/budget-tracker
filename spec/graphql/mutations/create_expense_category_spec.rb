# typed: false
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::CreateExpenseCategory do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let!(:budget) { create(:budget, user: user) }

  let(:variables) do
    {
      input: {
        params: {
          name: 'House',
          estimatedMonthlyExpense: 2000,
          budgetId: budget.id
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
    mutation createExpenseCategory($input: CreateExpenseCategoryInput!) {
      createExpenseCategory(input: $input) {
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
      result[:data][:createExpenseCategory][:expenseCategory]
  end

  def errors_data(result)
    result[:data][:createExpenseCategory][:errors]
  end

  context "Given a user" do

    it "should create the expense category with no errors" do
      result = nil
      expect do
        result = subject
      end.to change(Budget, :count).by(0)
      .and change(ExpenseCategory, :count).by(1)

      category = category_data(result)
      errors = errors_data(result)

      new_category = ExpenseCategory.last

      expect(new_category.name).to eq('House')
      expect(new_category.budget_id).to eq(budget.id)
      expect(new_category.estimated_monthly_expense).to eq(2000)
      expect(new_category.id).not_to be_blank

      expect(category[:name]).to eq('House')
      expect(category[:estimatedMonthlyExpense]).to eq(2000)
      expect(errors).to be_empty
    end
  end


  context "Errors" do
    context "Given another user" do
      let(:context) { { current_user: create(:user) } }

      it "should not create the expense category with error" do
        result = nil
        expect do
          result = subject
        end.to change(ExpenseCategory, :count).by(0)

        expense_category = category_data(result)
        errors = errors_data(result)

        expect(expense_category).to eq(nil)
        expect(errors).to eq(["Budget not found"])

      end
    end
    context "Given an invalid budget" do
      before { variables[:input][:params][:budgetId] = "INVALID_ID" }
      it "should not create the expense category with error" do
        result = nil
        expect do
          result = subject
        end.to change(ExpenseCategory, :count).by(0)

        expense_category = category_data(result)
        errors = errors_data(result)

        expect(expense_category).to eq(nil)
        expect(errors).to eq(["Budget not found"])

      end
    end
    context "Given a duplicate category name" do
      let!(:expsense_category) { create(:expense_category, name: 'House', budget: budget)}

      it "should not create the expense category with error" do
        result = nil
        expect do
          result = subject
        end.to change(ExpenseCategory, :count).by(0)

        expense_category = category_data(result)
        errors = errors_data(result)

        expect(expense_category).to eq(nil)
        expect(errors).to eq(["Expense category already exists for this budget"])

      end
    end
    context "Given no user is logged in" do
      let(:context) { { current_user: nil } }
      it_behaves_like "requires authentication"
    end
  end
end
