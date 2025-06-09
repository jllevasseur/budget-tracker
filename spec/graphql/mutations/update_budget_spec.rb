# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateBudget do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let!(:existing_budget) { create(:budget, :with_categories, user: user) }
  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        id: existing_budget.id,
        params: {
          name: '2025 new',
          year: 2024
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
      mutation updateBudget($input: UpdateBudgetInput!) {
        updateBudget(input: $input) {
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
    result[:data][:updateBudget][:budget]
  end

  def errors_data(result)
    result[:data][:updateBudget][:errors]
  end

  context 'Given a user' do
    it 'updates the budget with no errors' do
      result = nil
      expect do
        result = subject
      end.to change(Budget, :count).by(0)
                                   .and change(ExpenseCategory, :count).by(0)

      budget = budget_data(result)
      errors = errors_data(result)

      expect(budget[:name]).to eq('2025 new')
      expect(budget[:year]).to eq(2024)
      expect(budget[:user][:name]).to eq(user.name)
      expect(budget[:categories].size).to eq(3)
      expect(errors).to be_empty
    end
  end

  context 'Errors' do
    context 'Given an existing budget to update not belonging to the user' do
      let(:context) { { current_user: create(:user) } }

      it 'does not update the budget and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Budget, :count)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(['Budget not found'])
      end
    end

    context 'Given an invalid existing budget to duplicate' do
      before { variables[:input][:id] = 'INVALID_ID' }

      it 'does not update the budget and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Budget, :count)

        budget = budget_data(result)
        errors = errors_data(result)

        expect(budget).to eq(nil)
        expect(errors).to eq(['Budget not found'])
      end
    end

    context 'authorization' do
      it_behaves_like 'requires authentication'
    end
  end
end
