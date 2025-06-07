# frozen_string_literal: true

module Queries
  class BaseQuery < GraphQL::Schema::Resolver
    def current_user
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user
      user
    end
  end
end
