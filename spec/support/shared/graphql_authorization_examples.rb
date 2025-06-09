# frozen_string_literal: true

RSpec.shared_examples 'requires authentication' do
  it 'returns an Unauthorized error when no user is present' do
    result = execute_graphql_query(
      query_string: query_string,
      context: { current_user: nil },
      variables: defined?(variables) ? variables : {},
      expect_errors: true
    )

    expect(result).to include(
      errors: [hash_including(message: a_string_including('Unauthorized'))]
    )
  end

  it 'returns an Unauthorized error when user is not persisted' do
    result = execute_graphql_query(
      query_string: query_string,
      context: { current_user: build(:user) },
      variables: defined?(variables) ? variables : {},
      expect_errors: true
    )

    expect(result).to include(
      errors: [hash_including(message: a_string_including('Unauthorized'))]
    )
  end
end

RSpec.shared_examples 'requires resource ownership' do
  it 'returns an Unauthorized error when user is not the owner' do
    result = execute_graphql_query(
      query_string: query_string,
      context: { current_user: create(:user) },
      variables: defined?(variables) ? variables : {},
      expect_errors: true
    )

    expect(result).to include(
      errors: [hash_including(message: a_string_including('Unauthorized'))]
    )
  end
end
