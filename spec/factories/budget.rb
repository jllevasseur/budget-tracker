# frozen_string_literal: true

FactoryBot.define do
  factory :budget do
    name { "My Budget" }
    year { Faker::Number.between(from: 2026, to: 2030) }
    association :user

    trait :with_categories do
      after(:create) do |budget|
        create_list(:expense_category, 3, budget: budget)
      end
    end
  end
end
