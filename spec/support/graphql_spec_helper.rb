# frozen_string_literal: true

module GraphqlSpecHelper
  def execute_graphql_query(query_string:, context:, variables:, expect_errors: false)
    result = BudgetAppBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    ).to_h.deep_symbolize_keys

    if !expect_errors && result[:errors].present?
      puts "\nGraphQL errors: #{result[:errors].inspect}\n"
      expect(result[:errors]).to be_blank
    end

    result
  end

  def subject
    execute_graphql_query(query_string: query_string, context: context, variables: variables)
  end
end
