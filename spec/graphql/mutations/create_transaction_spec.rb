# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateTransaction do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, :with_categories, user: user, year: Date.today.year) }

  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        params: {
          description: 'groceries',
          amount: 120,
          budgetId: budget.id,
          expenseCategoryId: budget.categories[0].id,
          transactionType: 'EXPENSE',
          transactionDate: Date.today
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
        mutation createTransaction($input: CreateTransactionInput!) {
        createTransaction(input: $input) {
          transaction {
            id
            description
            amount
            expenseCategory {
             id
            }
            transactionDate
            transactionType
          }
          errors
        }
      }
    GRAPHQL
  end

  def transaction_data(result)
    result[:data][:createTransaction][:transaction]
  end

  def errors_data(result)
    result[:data][:createTransaction][:errors]
  end

  def expect_transaction_result(result, attrs)
    transaction = transaction_data(result)
    errors = errors_data(result)

    new_transaction = Transaction.last

    expect(new_transaction.description).to eq(attrs[:description])
    expect(new_transaction.amount).to eq(attrs[:amount])
    expect(new_transaction.id).not_to be_blank

    expect(transaction[:description]).to eq(attrs[:description])
    expect(transaction[:amount]).to eq(attrs[:amount])
    expect(errors).to be_empty
  end

  context 'Given a user' do
    context 'Given an expense' do
      it 'creates the expense transaction with no errors' do
        result = nil
        expect do
          result = subject
        end.to change(Transaction, :count).by(1)

        expect_transaction_result(result, description: 'groceries', amount: 120)
      end
    end
    context 'Given a refund' do
      before { variables[:input][:params][:transactionType] = 'REFUND' }
      it 'creates the refund transaction with no errors' do
        result = nil
        expect do
          result = subject
        end.to change(Transaction, :count).by(1)

        expect_transaction_result(result, description: 'groceries', amount: -120)
      end
    end
  end

  context 'Errors' do
    context 'Given another user' do
      let(:context) { { current_user: create(:user) } }

      it 'does not create the transaction and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Transaction, :count)

        expense_category = transaction_data(result)
        errors = errors_data(result)

        expect(expense_category).to eq(nil)
        expect(errors).to eq(['Budget not found or unauthorized'])
      end
    end
    context 'Given an invalid expense category' do
      before { variables[:input][:params][:expenseCategoryId] = 'INVALID_ID' }
      it 'does not create the transaction and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Transaction, :count)

        transaction = transaction_data(result)
        errors = errors_data(result)

        expect(transaction).to eq(nil)
        expect(errors).to eq(['Expense category not found'])
      end
    end

    context 'Given a transaction date outside the budget year' do
      before { variables[:input][:params][:transactionDate] = Date.today - 1.year - 2.days }
      it 'does not create the transaction and returns an error' do
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

    context 'authorization' do
      it_behaves_like 'requires authentication'
    end
  end
end
