class Transaction < ApplicationRecord
  belongs_to :expense_category

  enum transaction_type: {
    expense: 'expense',
    refund: 'refund'
  }

  before_save :normalize_refund_amount

  private

  def normalize_refund_amount
    self.amount = if refund?
                    -amount.abs
                  else
                    amount.abs
                  end
  end
end
