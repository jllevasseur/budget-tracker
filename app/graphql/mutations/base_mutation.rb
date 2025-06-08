# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def current_user
      user = context[:current_user]
      raise GraphQL::ExecutionError, 'Unauthorized' unless user

      user
    end
  end
end
