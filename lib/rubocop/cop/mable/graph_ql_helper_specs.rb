# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # The graphql path may change avoid hardcoding and use the url helper instead.
      #
      # @example
      #
      #   # bad
      #   post '/graphql'
      #
      #   # good
      #   post graphql_path
      #
      class GraphQLHelperSpecs < Base
        extend AutoCorrector

        MSG = 'Avoid hardcoding GraphQL URL paths, instead, use the helper method.'

        RESTRICT_ON_SEND = %i[post].freeze

        def_node_matcher :post_graphql?, <<~PATTERN
          (send nil? :post (str "/graphql") ...)
        PATTERN

        def on_send(node)
          return unless post_graphql?(node)

          add_offense(node) do |corrector|
            corrector.replace(node.location.expression, 'post grapql_path')
          end
        end
      end
    end
  end
end
