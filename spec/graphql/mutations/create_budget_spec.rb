# typed: false
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::CreateBudget do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        params: {
          name: '2025',
          year: 2025,
          userId: user.id
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
    mutation createBudget($input: CreateBudgetInput!) {
      createBudget(input: $input) {
        budget {
          id
          name
          year
          user {
            name
          }
          categories {
            name
          }
        }
        errors
      }
    }
    GRAPHQL
  end

  def budget_data(result)
      result[:data][:createBudget][:budget]
  end

  def errors_data(result)
    result[:data][:createBudget][:errors]
  end

  context "Given a user" do
    def expect_valid_budget_response(result, user, expected_category_count: 0, expected_name: '2025', expected_year: 2025)
      budget = budget_data(result)
      errors = errors_data(result)

      new_budget = Budget.last

      expect(new_budget.name).to eq(expected_name)
      expect(new_budget.user_id).to eq(user.id)
      expect(new_budget.id).not_to be_blank

      expect(budget[:name]).to eq(expected_name)
      expect(budget[:year]).to eq(expected_year)
      expect(budget[:user][:name]).to eq(user.name)
      expect(budget[:categories].size).to eq(expected_category_count)
      expect(errors).to be_empty
    end


    it "should create the budget with no errors" do
      result = nil
      expect do
        result = subject
      end.to change(Budget, :count).by(1)
      .and change(ExpenseCategory, :count).by(0)

      expect_valid_budget_response(result, user)
    end

    context "When duplicating from an existing budget" do
      let(:existing_budget) { create(:budget, :with_categories, user: user) }

      before { variables[:input][:params][:duplicateFromBudgetId] = existing_budget.id }

      it "should create the budget and duplicates the categories with no errors" do
        result = nil
        expect do
          result = subject
        end.to change(Budget, :count).by(1)
        .and change(ExpenseCategory, :count).by(existing_budget.categories.size)

        expect_valid_budget_response(result, user, expected_category_count: existing_budget.categories.size)
      end
    end
  end


  context "Errors" do
    context "Given another user" do
      let(:context) { { current_user: create(:user) } }
      it "should not create the budget an error should be unautorized" do
        result = nil
        expect do
          result = subject
        end.to change(Budget, :count).by(0)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(["Unauthorized"])

      end
    end
    context "Given an invalid user" do
      before { variables[:input][:params][:userId] = "INVALID_ID" }
      it "should not create the budget with error" do
        result = nil
        expect do
          result = subject
        end.to change(Budget, :count).by(0)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(["User not found"])

      end
    end
    context "Given an invalid existing budget to duplicate" do
      before { variables[:input][:params][:duplicateFromBudgetId] = "INVALID_ID" }

      it "should not create the budget with error" do
        result = nil
        expect do
          result = subject
        end.to change(Budget, :count).by(0)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(["User not authorized to duplicate this budget"])

      end
    end
    context "Given an existing budget to duplicate not belonging to the user" do
      let!(:invalid_existing_budget) { create(:budget, :with_categories, user: create(:user)) }
      before { variables[:input][:params][:duplicateFromBudgetId] = invalid_existing_budget.id }

      it "should not create the budget with error" do
        result = nil
        expect do
          result = subject
        end.to change(Budget, :count).by(0)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(["User not authorized to duplicate this budget"])
      end
    end
    context "Given no user is logged in" do
      let(:context) { { current_user: nil } }
      it_behaves_like "requires authentication"
    end
  end
end
