class Transaction < ApplicationRecord
  belongs_to :expense_category

  enum transaction_type: {
    expense:  'expense',
    refund:   'refund',
  }

  before_save :normalize_refund_amount

  private

  def normalize_refund_amount
    if refund?
      self.amount = -amount.abs
    else
      self.amount = amount.abs
    end
  end
end
