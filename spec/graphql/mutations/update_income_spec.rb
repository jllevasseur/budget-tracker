# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateIncome do
  include GraphqlSpecHelper

  let(:user) { create(:user) }
  let(:budget) { create(:budget, user: user, year: Date.today.year) }
  let!(:income) do
    create(:income, description: 'Salary', amount: 2000, budget: budget)
  end
  let(:context) { { current_user: user } }

  let(:variables) do
    {
      input: {
        id: income.id,
        params: {
          description: 'Gift',
          amount: 2500,
          transactionDate: Date.today
        }
      }
    }
  end

  let(:query_string) do
    <<~GRAPHQL
      mutation updateIncome($input: UpdateIncomeInput!) {
        updateIncome(input: $input) {
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
    result[:data][:updateIncome][:income]
  end

  def errors_data(result)
    result[:data][:updateIncome][:errors]
  end

  context 'Given a user' do
    it 'updates the income with no errors' do
      result = nil
      expect do
        result = subject
      end.not_to change(Income, :count)

      income = income_data(result)
      errors = errors_data(result)

      expect(income[:description]).to eq('Gift')
      expect(income[:amount]).to eq(2500)

      expect(errors).to be_empty
    end
  end

  context 'Errors' do
    context 'Given an income not belonging to the user' do
      it_behaves_like 'requires resource ownership'
    end

    context 'Given a transaction date outside the budget year' do
      before { variables[:input][:params][:transactionDate] = Date.today - 1.year - 2.days }
      it 'does not update the income and returns an error' do
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
