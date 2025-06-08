# frozen_string_literal: true

FactoryBot.define do
  factory :expense_category do
    sequence(:name) { |n| "#{Faker::Commerce.department} #{n}" }
    estimated_monthly_expense { 100 }
    association :budget
  end
end
