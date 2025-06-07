# frozen_string_literal: true

FactoryBot.define do
  factory :expense_category do
    name { Faker::Commerce.department }
    estimated_monthly_expense { 100 }
    association :budget
  end
end
