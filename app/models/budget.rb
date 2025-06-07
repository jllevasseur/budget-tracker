# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :user
  has_many :categories, class_name: 'ExpenseCategory', dependent: :destroy
  has_many :transactions, through: :expense_categories
  has_many :incomes, dependent: :destroy
end
