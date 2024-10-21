# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # We are in the process of transitioning out the old FeatureFlags::Client and
      # want people to be using FeatureFlags::Repo
      #
      # @example
      #
      #   # bad
      #   FeatureFlags::Client.get_feature_flag("test", uuid: user.id)
      #
      #   # good
      #   FeatureFlags::Repo.get_feature_flag("test", uuid: user.id)
      #
      class UsingDeprecatedFFClient < Base
        extend AutoCorrector

        MSG = 'FeatureFlags::Client is deprecated, please use FeatureFlags::Repo'

        def_node_matcher :deprecated_ff_client?, <<~PATTERN
          `(const (const nil? :FeatureFlags) :Client)
        PATTERN

        def on_send(node)
          expression = deprecated_ff_client?(node)
          return unless expression

          add_offense(node) do |corrector|
            replacement = node.source.sub('FeatureFlags::Client', 'FeatureFlags::Repo')
            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
