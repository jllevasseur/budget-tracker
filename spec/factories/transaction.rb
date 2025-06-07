# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    transaction_date { Date.today }
    amount { 50.0 }
    transaction_type { :expense }
    expense_category

    trait :refund do
      transaction_type { :refund }
      amount { -50.0 }
    end

    trait :with_date do
      transient do
        date { Date.today }
      end

      transaction_date { date }
    end
  end
end
