# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # Hardcoding factory bot Database IDs can cause race conditions
      # if there are database unique constraints on the column
      #
      # @safety
      #   Cop is unsafe because test cases may rely on the ID
      #
      # @example
      #   # bad
      #   Factoybot.create(:user, id: 1000)
      #
      #   expect(user.id).to eq 1000
      #
      #   # bad
      #   create(:user, id: 1000)
      #
      #   expect(user.id).to eq 1000
      #
      #   # good
      #   Factoybot.create(:user)
      #
      #   expect(user.id).to eq user.id
      #
      #   # good
      #   create(:user)
      #   let(:user_id) { user.id }
      #
      #   expect(user.id).to eq user_id

      class HardcodedDatabaseFactoryBotId < Base
        MSG = 'Avoid hardcoding Factory Bot database IDs, instead, let the factory set the ID and test the result'

        RESTRICT_ON_SEND = %i[
          create
          create_list
          create_pair
          generate
          generate_list
        ].to_set.freeze

        # @!method hardcoded_factory_bot_primary_key?(node)
        def_node_matcher :hardcoded_factory_bot_primary_key?, <<~PATTERN
          (send { _ | (const ... :FactoryBot) } _
            (sym _)*
            (hash
              <(pair
                (sym :id) (...)
              ) pair ...>
            )
          )
        PATTERN

        def on_send(node)
          return unless hardcoded_factory_bot_primary_key?(node)

          add_offense(node)
        end
      end
    end
  end
end
