# frozen_string_literal: true

module Types
  class TransactionTypeEnum < Types::BaseEnum
    value 'EXPENSE', 'Expense transaction', value: 'expense'
    value 'REFUND', 'Return transaction', value: 'refund'
  end
end
