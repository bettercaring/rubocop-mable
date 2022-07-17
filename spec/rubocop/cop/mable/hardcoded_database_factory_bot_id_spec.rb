# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Mable::HardcodedDatabaseFactoryBotId, :config do
  let(:config) { RuboCop::Config.new }

  shared_examples 'code that registers an offense' do
    it 'registers an offense' do
      expect_offense(
        <<~RUBY
          #{code}
          #{'^' * code.length} #{offense_msg}
        RUBY
      )
    end
  end

  shared_examples 'code that does not register an offense' do
    it 'does not register an offense' do
      expect_no_offenses(
        <<~RUBY
          #{code}
        RUBY
      )
    end
  end

  context 'when registering an offense' do
    let(:offense_msg) do
      'Avoid hardcoding Factory Bot database IDs, instead, let the factory set the ID and test the result'
    end

    describe '#create' do
      let(:code) { 'create(:user, first_name: "Mable", id: 10000)' }

      it_behaves_like 'code that registers an offense'
    end

    describe '#build' do
      let(:code) { 'build(:user, first_name: "Mable", id: 10000)' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'FactoryBot.create' do
      let(:code) { 'FactoryBot.create(:user, id: 10000, first_name: "Mable")' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'FactoryBot.build' do
      let(:code) { 'FactoryBot.build(:user, first_name: "Mable", id: 10000, last_name: "Dorothy")' }

      it_behaves_like 'code that registers an offense'
    end

    context 'when including traits' do
      let(:code) { 'FactoryBot.build(:user, :admin, first_name: "Mable", id: 10000, last_name: "Dorothy")' }

      it_behaves_like 'code that registers an offense'
    end
  end

  context 'when not registering an offense' do
    describe 'hash' do
      let(:code) { "{ first_name: 'Mable', id: 10000, last_name: 'Dorothy' }" }

      it_behaves_like 'code that does not register an offense'
    end

    describe 'keyword arguments' do
      let(:code) { "do_stuff(first_name: 'Mable', id: 10000, last_name: 'Dorothy')" }

      it_behaves_like 'code that does not register an offense'
    end

    describe 'FactoryBot.create' do
      let(:code) { "create(first_name: 'Mable', last_name: 'Dorothy')" }

      it_behaves_like 'code that does not register an offense'
    end

    describe 'FactoryBot.build' do
      let(:code) { "build(first_name: 'Mable', last_name: 'Dorothy')" }

      it_behaves_like 'code that does not register an offense'
    end
  end
end
