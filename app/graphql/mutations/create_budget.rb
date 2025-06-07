# frozen_string_literal: true

class Mutations::CreateBudget < Mutations::BaseMutation
  argument :params, Types::Input::BudgetCreateInput, required: true

  field :budget, Types::BudgetType, null: true
  field :errors, [String], null: false

  def resolve(params:)
    attributes = params.to_h
    user_id = attributes[:user_id]
    year = attributes[:year]
    duplicate_from_budget_id = attributes.delete(:duplicate_from_budget_id)

    authorized_user = current_user

    user = User.find_by(id: user_id)

    return { budget: nil, errors: ["User not found"] } unless user
    return { budget: nil, errors: ["Unauthorized"] } unless user == authorized_user

    existing_budget = Budget.find_by(user_id: user.id, year: year)
    if existing_budget
      return {
        budget: nil,
        errors: ["A budget for that year already exists for this user"]
      }
    end

    original_budget = nil
    if duplicate_from_budget_id.present?
      original_budget = user.budgets.find_by(id: duplicate_from_budget_id)
      unless original_budget
        return { budget: nil, errors: ["User not authorized to duplicate this budget"] }
      end
    end

    budget = nil
    errors = []

    Budget.transaction do
      budget = Budget.new(attributes)

      if budget.save
        if original_budget
          # duplicate categories
          original_budget.categories.each do |category|
            budget.categories.create!(name: category.name)
          end
        end
      else
        errors = budget.errors.full_messages
        raise ActiveRecord::Rollback
      end
    end

    { budget: budget, errors: errors }
  end
end
