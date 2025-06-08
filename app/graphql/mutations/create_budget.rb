# frozen_string_literal: true

class Mutations::CreateBudget < Mutations::BaseMutation
  argument :params, Types::Input::BudgetCreateInput, required: true

  field :budget, Types::BudgetType, null: true
  field :errors, [String], null: false

  def resolve(params:)
    attributes = params.to_h
    attributes[:user_id] = current_user.id

    year = attributes[:year]
    duplicate_from_budget_id = attributes.delete(:duplicate_from_budget_id)

    if Budget.exists?(user_id: current_user.id, year: year)
      return { budget: nil, errors: ['A budget for that year already exists for this user'] }
    end

    original_budget = nil
    if duplicate_from_budget_id.present?
      original_budget = current_user.budgets.find_by(id: duplicate_from_budget_id)
      return { budget: nil, errors: ['User not authorized to duplicate this budget'] } unless original_budget
    end

    budget = nil
    errors = []

    Budget.transaction do
      budget = Budget.new(attributes)

      if budget.save
        if original_budget
          begin
            duplicate_categories(budget, original_budget)
          rescue StandardError => e
            errors << "Failed to duplicate categories: #{e.message}"
            raise ActiveRecord::Rollback
          end
        end
      else
        errors = budget.errors.full_messages
        raise ActiveRecord::Rollback
      end
    end

    { budget: budget, errors: errors }
  end

  private

  def duplicate_categories(new_budget, original_budget)
    categories_attrs = original_budget.categories.map do |category|
      {
        name: category.name,
        budget_id: new_budget.id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    ExpenseCategory.insert_all!(categories_attrs)
  end
end
