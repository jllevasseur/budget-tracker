# frozen_string_literal: true

module Support::AuthHelper
  def current_user
    user = context[:current_user]
    raise GraphQL::ExecutionError, 'Unauthorized' unless user

    persisted_user = User.find_by(id: user.id)
    raise GraphQL::ExecutionError, 'Unauthorized' unless persisted_user

    persisted_user
  end

  def authorize_owner!(resource)
    raise GraphQL::ExecutionError, 'Unauthorized' unless resource&.user == current_user
  end
end
