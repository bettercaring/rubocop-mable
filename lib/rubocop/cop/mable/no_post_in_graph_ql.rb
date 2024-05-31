# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # Enforces using a direct helper method over `post` for executing GraphQL queries,
      # incorporating user authentication context when applicable.
      #
      # @safety
      #   The cop is unsafe as user might not exist or not be called user.
      #
      # @example
      #
      #   # bad
      #   post graphql_path, params: { query: my_query, variables: my_variables }, as: :json
      #
      #   # good
      #   execute_graphql(query: my_query, variables: my_variables, user: current_user)
      #
      class NoPostInGraphQL < Base
        extend AutoCorrector

        MSG = 'Use `make_graphql_request` directly instead of `post` for GraphQL requests, incorporating user context.'

        RESTRICT_ON_SEND = %i[post].freeze

        def_node_matcher :post_graphql?, <<~PATTERN
          (send nil? :post
            (str _)
            (hash
              (pair
                (sym :params)
                (hash
                  (pair (sym :query) _)
                  (pair (sym :variables) _)
                )
              )
              (pair
                (sym :as)
                (sym :json)
              )
            )
          )
        PATTERN

        def_node_search :rspec_block?, <<~PATTERN
          (block (send (const nil? :RSpec) {:describe :context :it} ...) ...)
        PATTERN

        def on_send(node)
          return unless within_rspec_block?(node)

          # Check if the method is `post` and it includes `params:`
          params_pair = node.arguments.find do |arg|
            arg.hash_type? && arg.pairs.any? { |pair| pair.key.sym_type? && pair.key.value == :params }
          end

          return unless params_pair

          # Access pairs directly from params_pair
          params_hash = params_pair.pairs.find { |pair| pair.key.value == :params }.value

          return unless params_hash.hash_type?

          query_pair = params_hash.pairs.find { |p| p.key.value == :query }
          variables_pair = params_hash.pairs.find { |p| p.key.value == :variables }

          query = query_pair&.value&.source
          variables = variables_pair&.value&.source

          replacement = cop_config['ReplacePostWith'] || 'make_graphql_request'
          execute_call = "#{replacement}(query: #{query}"
          execute_call += ', user: user'
          execute_call += ", variables: #{variables}" if variables
          execute_call += ')'

          add_offense(node) do |corrector|
            corrector.replace(node.loc.expression, execute_call)
          end
        end

        private

        def within_rspec_block?(node)
          node.each_ancestor.any? { |ancestor| rspec_block?(ancestor) }
        end

        def find_login_as_user(node)
          # Find the topmost describe/context block
          rspec_root = node.each_ancestor.find { |ancestor| rspec_block?(ancestor) }
          return unless rspec_root
        end
      end
    end
  end
end
