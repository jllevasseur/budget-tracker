# typed: false
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::DeleteBudget do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let!(:budget) { create(:budget, :with_categories, user: user) }
  let(:context) { { current_user: user } }

  let(:variables) { { input: { id: budget.id } } }

  let(:query_string) do
    <<~GRAPHQL
    mutation deleteBudget($input: DeleteBudgetInput!) {
      deleteBudget(input: $input) {
        success
        errors
      }
    }
    GRAPHQL
  end

  context "Given a user" do
    it "should delete the budget with no errors" do
      result = nil
      expect do
        result = subject
      end.to change(Budget, :count).by(-1)
      .and change(ExpenseCategory, :count).by(-3)

      response = result[:data][:deleteBudget]

      expect(response[:success]).to be true
      expect(response[:errors]).to be_empty

    end
  end

  context "Errors" do
    context "Given a budget that does not exist" do
      let(:variables) { { input: { id: "invalid-id" } } }

      it "should return an error and does not delete budget" do
        result = nil
        expect do
          result = subject
        end.not_to change(Budget, :count)

        response = result[:data][:deleteBudget]
        expect(response[:success]).to be false
        expect(response[:errors]).to include("Budget not found")
      end
    end
    context "Given no user is logged in" do
      let(:context) { { current_user: nil } }
      it_behaves_like "requires authentication"
    end
  end
end
