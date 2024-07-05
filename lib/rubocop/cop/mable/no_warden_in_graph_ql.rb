# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # This cop checks for the usage of Warden::Test::Helpers and related
      # methods within GraphQL specs. It disallows the use of Warden.test_mode!,
      # login_as, and user.reload.
      #
      # @safety
      #   Unsafe as requires graphql helper method to replace
      #
      # @example
      #   # bad
      #   Warden.test_mode!
      #   login_as(user)
      #   user.reload
      #   include Warden::Test::Helpers
      #
      #   # good
      #   # Use graphql helper method
      class NoWardenInGraphQL < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Do not use `%<method>s` in GraphQL specs. Use graphql helper method instead.'

        RESTRICT_ON_SEND = %i[test_mode! login_as reload].freeze
        RESTRICT_ON_INCLUDE = %i[Warden::Test::Helpers].freeze

        def_node_search :rspec_describe_graphql?, <<~PATTERN
          (block
            (send (const nil? :RSpec) :describe
              (const { (const nil? {:Graphql :Queries :Mutations}) } _)
              ...)
            ...)
        PATTERN

        def_node_matcher :user_reload?, <<~PATTERN
          (send
            (send _ :user) :reload)
        PATTERN

        def on_send(node)
          return unless in_graphql?(node) && bad_method?(node)

          method_name = node.method_name
          add_offense(node, message: format(MSG, method: method_name)) do |corrector|
            correct_offense(corrector, node)
          end
        end

        def on_const(node)
          return unless in_graphql?(node) && bad_include?(node)

          add_offense(node, message: format(MSG, method: 'include Warden::Test::Helpers')) do |corrector|
            correct_offense(corrector, node)
          end
        end

        private

        def in_graphql?(node)
          node.each_ancestor(:block).any? do |ancestor|
            rspec_describe_graphql?(ancestor)
          end
        end

        def bad_method?(node)
          if node.method_name == :reload
            user_reload?(node)
          else
            RESTRICT_ON_SEND.include?(node.method_name)
          end
        end

        def bad_include?(node)
          RESTRICT_ON_INCLUDE.include?(node.const_name.to_sym)
        end

        def correct_offense(corrector, node)
          if node.send_type? && bad_method?(node)
            corrector.remove(range_with_comments_and_lines(node))
          elsif node.const_type? && node.const_name == 'Warden::Test::Helpers'
            corrector.remove(range_with_comments_and_lines(node.parent))
          end
        end
      end
    end
  end
end
