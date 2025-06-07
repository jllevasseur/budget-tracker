# typed: false
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::DeleteExpenseCategory do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let!(:budget) { create(:budget, :with_categories, user: user) }
  let!(:expense_category) {
    create(:expense_category, budget: budget)
  }
  let(:context) { { current_user: user } }

  let(:variables) { { input: { id: expense_category.id } } }

  let(:query_string) do
    <<~GRAPHQL
    mutation deleteExpenseCategory($input: DeleteExpenseCategoryInput!) {
      deleteExpenseCategory(input: $input) {
        success
        errors
      }
    }
    GRAPHQL
  end

  context "Given a user" do
    it "should delete the expense category with no errors" do
      result = nil
      expect do
        result = subject
      end.to change(ExpenseCategory, :count).by(-1)
      .and change(Transaction, :count).by(0)

      response = result[:data][:deleteExpenseCategory]

      expect(response[:success]).to be true
      expect(response[:errors]).to be_empty

    end
  end

  context "Errors" do
    context "Given a expense category that does not exist" do
      let(:variables) { { input: { id: "invalid-id" } } }

      it "should not delete expense category with error" do
        result = nil
        expect do
          result = subject
        end.not_to change(ExpenseCategory, :count)

        response = result[:data][:deleteExpenseCategory]
        expect(response[:success]).to be false
        expect(response[:errors]).to include("Expense category not found")
      end
    end
    context "Given a expense category that does not belong to the user" do
      let!(:existing_budget) { create(:budget, :with_categories, user: create(:user)) }
      let(:variables) { { input: { id: existing_budget.categories[0].id } } }

      it "should not delete expense category with error" do
        result = nil
        expect do
          result = subject
        end.not_to change(ExpenseCategory, :count)

        response = result[:data][:deleteExpenseCategory]
        expect(response[:success]).to be false
        expect(response[:errors]).to include("Unauthorized")
      end
    end
    context "Given no user is logged in" do
      let(:context) { { current_user: nil } }
      it_behaves_like "requires authentication"
    end
  end
end
