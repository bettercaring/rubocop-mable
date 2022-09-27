# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mable::GraphQLHelperSpecs, :config do
  let(:config) { RuboCop::Config.new }
  let(:offense_msg) do
    'Avoid hardcoding GraphQL URL paths, instead, use the helper method.'
  end

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

  context 'when not using url path helper' do
    context 'with params' do
      let(:code) { "post '/graphql', params: { query: graphql_query }" }

      it_behaves_like 'code that registers an offense'
    end

    context 'without params' do
      let(:code) { "post '/graphql'" }

      it_behaves_like 'code that registers an offense'
    end
  end

  context 'when using url path helper' do
    context 'with params' do
      let(:code) { "post graphql_path, params: { query: graphql_query }" }

      it_behaves_like 'code that does not register an offense'
    end

    context 'without params' do
      let(:code) { "post graphql_path" }

      it_behaves_like 'code that does not register an offense'
    end
  end
end

