# frozen_string_literal: true

FactoryBot.define do
  factory :income do
    transaction_date { Date.today }
    amount { 50.0 }
    description { 'salary' }
  end
end
