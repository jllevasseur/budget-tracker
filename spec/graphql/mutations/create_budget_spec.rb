# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateBudget do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        params: {
          name: '2025',
          year: 2025
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
              id
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

  context 'Given a user' do
    def expect_valid_budget_response(
      result,
      user_id:,
      expected_category_count: 0,
      expected_name: '2025',
      expected_year: 2025
    )
      budget = budget_data(result)
      errors = errors_data(result)

      new_budget = Budget.last

      expect(new_budget.name).to eq(expected_name)
      expect(new_budget.user_id).to eq(user_id)
      expect(new_budget.id).not_to be_blank

      expect(budget[:name]).to eq(expected_name)
      expect(budget[:year]).to eq(expected_year)
      expect(budget[:user][:id].to_i).to eq(user_id)
      expect(budget[:categories].size).to eq(expected_category_count)
      expect(errors).to be_empty
    end

    it 'creates the budget with no errors' do
      result = nil
      expect do
        result = subject
      end.to change(Budget, :count).by(1)
                                   .and change(ExpenseCategory, :count).by(0)

      expect_valid_budget_response(result, user_id: user.id)
    end

    context 'When duplicating from an existing budget' do
      let(:existing_budget) { create(:budget, :with_categories, user: user) }

      before { variables[:input][:params][:duplicateFromBudgetId] = existing_budget.id }

      it 'creates the budget and duplicates the categories with no errors' do
        result = nil
        expect do
          result = subject
        end.to change(Budget, :count).by(1)
           .and change(ExpenseCategory, :count).by(existing_budget.categories.size)

        expect_valid_budget_response(result, user_id: user.id, expected_category_count: 3)
      end
    end
  end

  context 'Errors' do
    context 'Given an invalid existing budget to duplicate' do
      before { variables[:input][:params][:duplicateFromBudgetId] = 'INVALID_ID' }
      it 'does not create the budget and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Budget, :count)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(['User not authorized to duplicate this budget'])
      end
    end
    context 'Given an existing budget to duplicate not belonging to the user' do
      let(:invalid_existing_budget) { create(:budget, :with_categories, user: create(:user)) }
      before { variables[:input][:params][:duplicateFromBudgetId] = invalid_existing_budget.id }

      it 'does not create the budget and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Budget, :count)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(['User not authorized to duplicate this budget'])
      end
    end
    context 'authorization' do
      it_behaves_like 'requires authentication'
    end
  end
end
