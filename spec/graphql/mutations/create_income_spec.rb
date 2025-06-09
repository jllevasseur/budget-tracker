# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateIncome do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, user: user, year: Date.today.year) }

  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        params: {
          description: 'salary',
          amount: 2000,
          budgetId: budget.id,
          transactionDate: Date.today
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
        mutation createIncome($input: CreateIncomeInput!) {
        createIncome(input: $input) {
        income {
            id
            description
            amount
            transactionDate
          }
          errors
        }
      }
    GRAPHQL
  end

  def income_data(result)
    result[:data][:createIncome][:income]
  end

  def errors_data(result)
    result[:data][:createIncome][:errors]
  end

  context 'Given a user' do
    context 'Given an income' do
      it 'creates the income with no errors' do
        result = nil
        expect do
          result = subject
        end.to change(Income, :count).by(1)

        income = income_data(result)
        errors = errors_data(result)

        new_income = Income.last

        expect(new_income.description).to eq('salary')
        expect(new_income.amount).to eq(2000)
        expect(new_income.id).not_to be_blank

        expect(income[:description]).to eq('salary')
        expect(income[:amount]).to eq(2000)
        expect(errors).to be_empty
      end
    end
  end

  context 'Errors' do
    context 'Given another user' do
      let(:context) { { current_user: create(:user) } }

      it 'does not create the income and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Income, :count)

        income = income_data(result)
        errors = errors_data(result)

        expect(income).to eq(nil)
        expect(errors).to eq(['Budget not found or unauthorized'])
      end
    end
    context 'Given an invalid budget' do
      before { variables[:input][:params][:budgetId] = 'INVALID_ID' }
      it 'does not create the income and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Income, :count)

        income = income_data(result)
        errors = errors_data(result)

        expect(income).to eq(nil)
        expect(errors).to eq(['Budget not found or unauthorized'])
      end
    end

    context 'Given a transaction date outside the budget year' do
      before { variables[:input][:params][:transactionDate] = Date.today - 1.year - 2.days }
      it 'does not create the income and returns an error' do
        result = nil
        expect do
          result = subject
        end.not_to change(Income, :count)

        income = income_data(result)
        errors = errors_data(result)

        expect(income).to eq(nil)
        expect(errors).to eq(["Transaction date must be within the budget year #{budget.year}"])
      end
    end

    context 'authorization' do
      it_behaves_like 'requires authentication'
    end
  end
end
