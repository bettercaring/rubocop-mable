# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # An extra check to ensure that the safety_assured is required

      # @safety
      #   Can't be autocorrected because it's a manual check
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   safety_assured { remove_column :model_name....

      #   # good
      #   remove_column :model_name....

      class NoSafetyAssured < Base
        MSG = 'Are you sure safety_assured is required, is there a better way?'

        RESTRICT_ON_SEND = %i[safety_assured].freeze

        # @!method bad_method?(node)
        def_node_matcher :safety_assured?, <<~PATTERN
          (send nil? :safety_assured ...)
        PATTERN

        def on_send(node)
          return unless safety_assured?(node)

          add_offense(node)
        end
      end
    end
  end
end
