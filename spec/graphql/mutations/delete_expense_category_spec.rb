# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteExpenseCategory do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, :with_categories, user: user) }
  let!(:expense_category) { create(:expense_category, budget: budget) }
  let!(:transaction) { create(:transaction, expense_category: expense_category) }
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

  def delete_category_response(result)
    result[:data][:deleteExpenseCategory]
  end

  context 'Given a user' do
    it 'deletes the expense category with no errors' do
      result = nil
      expect do
        result = subject
      end.to change(Transaction, :count).by(-1)
                                        .and change(ExpenseCategory, :count).by(-1)

      response = delete_category_response(result)

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
        end.not_to change(ExpenseCategory, :count)

        response = delete_category_response(result)
        expect(response[:success]).to be false
        expect(response[:errors]).to include('Expense category not found')
      end
    end
    context 'Given a expense category that does not belong to the user' do
      it_behaves_like 'requires resource ownership'
    end
    context 'authorization' do
      it_behaves_like 'requires authentication'
    end
  end
end
