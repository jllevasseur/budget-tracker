# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteIncome do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, :with_categories, user: user) }
  let!(:income) { create(:income, budget: budget) }

  let(:context) { { current_user: user } }

  let(:variables) { { input: { id: income.id } } }

  let(:query_string) do
    <<~GRAPHQL
      mutation deleteIncome($input: DeleteIncomeInput!) {
        deleteIncome(input: $input) {
          success
          errors
        }
      }
    GRAPHQL
  end

  def delete_income_response(result)
    result[:data][:deleteIncome]
  end

  context 'Given a user' do
    it 'deletes the income with no errors' do
      result = nil
      expect do
        result = subject
      end.to change(Income, :count).by(-1)

      response = delete_income_response(result)

      expect(response[:success]).to be true
      expect(response[:errors]).to be_empty
    end
  end

  context 'Errors' do
    context 'Given a expense category that does not exist' do
      let(:variables) { { input: { id: 'invalid-id' } } }

      it 'does not delete expense category and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Income, :count)

        response = delete_income_response(result)
        expect(response[:success]).to be false
        expect(response[:errors]).to include('Income not found')
      end
    end
    context 'Given an income that does not belong to the user' do
      let(:unauthorized_budget) { create(:budget, user: create(:user)) }
      let!(:unauthorized_income) { create(:income, budget: unauthorized_budget) }
      let(:variables) { { input: { id: unauthorized_income.id } } }

      it 'does not delete the income and returns an errorr' do
        result = nil
        expect do
          result = subject
        end.not_to change(Income, :count)

        response = delete_income_response(result)
        expect(response[:success]).to be false
        expect(response[:errors]).to include('Unauthorized')
      end
    end
    context 'Given no user is logged in' do
      let(:context) { { current_user: nil } }
      it_behaves_like 'requires authentication'
    end
  end
end
