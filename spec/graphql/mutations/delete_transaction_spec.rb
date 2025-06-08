# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteTransaction do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, :with_categories, user: user) }
  let(:expense_category) { create(:expense_category, budget: budget) }
  let!(:transaction) { create(:transaction, expense_category: expense_category) }
  let(:context) { { current_user: user } }

  let(:variables) { { input: { id: transaction.id } } }

  let(:query_string) do
    <<~GRAPHQL
      mutation deleteTransaction($input: DeleteTransactionInput!) {
        deleteTransaction(input: $input) {
          success
          errors
        }
      }
    GRAPHQL
  end
  def delete_transaction_response(result)
    result[:data][:deleteTransaction]
  end
  context 'Given a user' do
    it 'deletes the transaction with no errors' do
      result = nil
      expect do
        result = subject
      end.to change(Transaction, :count).by(-1)

      response = delete_transaction_response(result)

      expect(response[:success]).to be true
      expect(response[:errors]).to be_empty
    end
  end

  context 'Errors' do
    context 'Given a transaction that does not exist' do
      let(:variables) { { input: { id: 'invalid-id' } } }

      it 'does not delete the transaction and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Transaction, :count)

        response = delete_transaction_response(result)
        expect(response[:success]).to be false
        expect(response[:errors]).to include('Expense category not found')
      end
    end
    context 'Given a transaction that does not belong to the user' do
      let(:existing_budget) { create(:budget, :with_categories, user: create(:user)) }
      let!(:existing_transaction) { create(:transaction, expense_category: existing_budget.categories[0]) }
      let(:variables) { { input: { id: existing_transaction.id } } }

      it 'does not delete the transaction and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Transaction, :count)

        response = delete_transaction_response(result)
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
