# frozen_string_literal: true

module Mutations
  class DeleteIncome < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      income = Income.find_by(id: id)
      return failure_response('Income not found') unless income

      return failure_response('Unauthorized') unless income.budget&.user == current_user

      if income.destroy
        { success: true, errors: [] }
      else
        failure_response(income.errors.full_messages)
      end
    end

    private

    def failure_response(errors)
      { success: false, errors: Array(errors) }
    end
  end
end
