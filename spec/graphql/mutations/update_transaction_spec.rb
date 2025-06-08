# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateTransaction do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, user: user, year: Date.today.year) }
  let!(:expense_category) do
    create(:expense_category, estimated_monthly_expense: 2000, budget: budget)
  end
  let!(:transaction) { create(:transaction, expense_category: expense_category) }
  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        id: transaction.id,
        params: {
          description: 'gas',
          amount: 75,
          transactionDate: Date.today,
          expenseCategoryId: expense_category.id
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
      mutation updateTransaction($input: UpdateTransactionInput!) {
        updateTransaction(input: $input) {
          transaction {
              id
              description
              amount
              expenseCategory {
               id
              }
            }
          errors
        }
      }
    GRAPHQL
  end

  def transaction_data(result)
    result[:data][:updateTransaction][:transaction]
  end

  def errors_data(result)
    result[:data][:updateTransaction][:errors]
  end

  context 'Given a user' do
    it 'updates the transaction with no errors' do
      result = nil
      expect do
        result = subject
      end.not_to change(Transaction, :count)

      transaction = transaction_data(result)
      errors = errors_data(result)

      expect(transaction[:description]).to eq('gas')
      expect(transaction[:amount]).to eq(75)

      expect(errors).to be_empty
    end
  end

  context 'Errors' do
    context 'Given another user' do
      let(:context) { { current_user: create(:user) } }

      it 'does not update the transaction with error' do
        result = subject

        transaction = transaction_data(result)
        errors = errors_data(result)

        expect(transaction).to eq(nil)
        expect(errors).to eq(['Transaction not found or unauthorised'])
      end
    end

    context 'Given an transaction not belonging to the user' do
      let(:unauthorized_budget) { create(:budget, :with_categories, user: create(:user)) }
      let(:unauthorized_expense_category) do
        create(:expense_category, name: 'Home', estimated_monthly_expense: 2000, budget: unauthorized_budget)
      end
      before { variables[:input][:id] = unauthorized_expense_category.id }

      it 'does not create the transaction with error' do
        result = subject

        transaction = transaction_data(result)
        errors = errors_data(result)

        expect(transaction).to eq(nil)
        expect(errors).to eq(['Transaction not found or unauthorised'])
      end
    end

    context 'Given a transaction date outside the budget year' do
      before { variables[:input][:params][:transactionDate] = Date.today - 1.year - 2.days }
      it 'does not update the transaction with error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Income, :count)

        transaction = transaction_data(result)
        errors = errors_data(result)

        expect(transaction).to eq(nil)
        expect(errors).to eq(["Transaction date must be within the budget year #{budget.year}"])
      end
    end

    context 'Given no user is logged in' do
      let(:context) { { current_user: nil } }
      it_behaves_like 'requires authentication'
    end
  end
end
