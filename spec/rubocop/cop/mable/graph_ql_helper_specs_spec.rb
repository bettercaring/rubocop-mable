# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mable::GraphQLHelperSpecs, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  let(:offense_msg) do
    'Avoid hardcoding GraphQL URL paths, instead, use the helper method.'
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
      let(:code) { 'post graphql_path, params: { query: graphql_query }' }

      it_behaves_like 'code that does not register an offense'
    end

    context 'without params' do
      let(:code) { 'post graphql_path' }

      it_behaves_like 'code that does not register an offense'
    end
  end
end
