# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # ActiveRecord memoises a PredicateBuilder wrapping a model's arel_table in a
      # class-level ivar, the first time anything builds a relation for that model, and
      # nothing ever resets it. A stubbed arel_table can therefore be captured by that
      # memoised builder and outlive the example that installed the stub, breaking every
      # later hash-form where on the model in the same process. It presents as an
      # order-dependent flake in unrelated specs, a long way from its cause.
      #
      # @example
      #
      #   # bad
      #   allow(described_class).to receive(:arel_table).and_return(arel_table)
      #
      #   # bad
      #   allow(described_class).to receive_messages(arel_table: arel_table)
      #
      #   # good - exercise the scope against the database
      #   create(:carer_profile, first_approval: cutoff + 1.day)
      #   expect(described_class.approved_after(cutoff)).to eq([profile])
      #
      #   # good - match on real Arel nodes, which compare structurally
      #   allow(relation).to receive(:where).with(described_class.arel_table[:created_at].gt(now))
      #
      class NoArelTableStub < Base
        MSG = 'Do not stub arel_table. ActiveRecord memoises a PredicateBuilder around it for the ' \
              'lifetime of the process, so the stub outlives this example and breaks later queries ' \
              'on the model. Test the scope against the database instead.'

        RESTRICT_ON_SEND = %i[receive have_received receive_messages].freeze

        def_node_matcher :arel_table_stub?, <<~PATTERN
          (send nil? {:receive :have_received} (sym :arel_table))
        PATTERN

        def_node_matcher :arel_table_messages_stub?, <<~PATTERN
          (send nil? :receive_messages (hash <(pair (sym :arel_table) _) ...>))
        PATTERN

        def on_send(node)
          return unless arel_table_stub?(node) || arel_table_messages_stub?(node)

          add_offense(node)
        end
      end
    end
  end
end
