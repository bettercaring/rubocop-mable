# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Mable::NoArelTableStub, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  context 'when registering an offense' do
    let(:offense_msg) do
      'Do not stub arel_table. ActiveRecord memoises a PredicateBuilder around it for the ' \
        'lifetime of the process, so the stub outlives this example and breaks later queries ' \
        'on the model. Test the scope against the database instead.'
    end

    describe 'receive' do
      let(:code) { 'allow(described_class).to receive(:arel_table).and_return(arel_table)' }
      let(:offense_method) { 'receive(:arel_table)' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'receive with no and_return' do
      let(:code) { 'allow(Message).to receive(:arel_table)' }
      let(:offense_method) { 'receive(:arel_table)' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'expect with receive' do
      let(:code) { 'expect(described_class).to have_received(:arel_table)' }
      let(:offense_method) { 'have_received(:arel_table)' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'receive_messages' do
      let(:code) { 'allow(described_class).to receive_messages(arel_table: arel_table)' }
      let(:offense_method) { 'receive_messages(arel_table: arel_table)' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'receive_messages alongside other messages' do
      let(:code) { 'allow(described_class).to receive_messages(default_scoped: scope, arel_table: arel_table)' }
      let(:offense_method) { 'receive_messages(default_scoped: scope, arel_table: arel_table)' }

      it_behaves_like 'code that registers an offense'
    end
  end

  context 'when not registering an offense' do
    describe 'stubbing a different message' do
      let(:code) { 'allow(described_class).to receive(:default_scoped).and_return(default_scope)' }

      it_behaves_like 'code that does not register an offense'
    end

    describe 'receive_messages without arel_table' do
      let(:code) { 'allow(described_class).to receive_messages(default_scoped: default_scope)' }

      it_behaves_like 'code that does not register an offense'
    end

    describe 'calling arel_table for real' do
      let(:code) { 'CarerProfile.arel_table[:first_approval]' }

      it_behaves_like 'code that does not register an offense'
    end

    describe 'a let named arel_table' do
      let(:code) { 'let(:arel_table) { described_class.arel_table }' }

      it_behaves_like 'code that does not register an offense'
    end
  end
end
