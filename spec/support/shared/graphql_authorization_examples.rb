# frozen_string_literal: true

RSpec.shared_examples "requires authentication" do
  it "returns an Unauthorized error" do
    result = execute_graphql_query(
      query_string:  query_string,
      context:       { current_user: nil },
      variables:     defined?(variables) ? variables : {},
      expect_errors: true,
    )

    expect(result).to include(
      errors: [hash_including(message: a_string_including("Unauthorized"))],
    )
  end
end
