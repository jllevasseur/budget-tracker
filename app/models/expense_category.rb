# frozen_string_literal: true

class ExpenseCategory < ApplicationRecord
  belongs_to :budget
  has_many :transactions, dependent: :destroy

  validates :name, presence: true,
                 uniqueness: { scope: :budget_id, case_sensitive: false }
end
