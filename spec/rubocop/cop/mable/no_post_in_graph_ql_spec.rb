# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mable::NoPostInGraphQL, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  let(:offense_msg) do
    "Use 'ReplacePostWith' default: `make_graphql_request` directly instead of `post` for GraphQL requests, incorporating user context."
  end

  context 'when using post in GraphQL specs' do
    context 'with query and path as string' do
      let(:code) { "RSpec.describe 'GraphQL' do #{offense_method} end" }
      let(:offense_method) { "post '/graphql', params: { query: graphql_query }" }

      it_behaves_like 'code that registers an offense'
    end

    context 'with query and path as helper' do
      let(:code) { "RSpec.describe 'GraphQL' do #{offense_method} end" }
      let(:offense_method) { "post '/graphql', params: { query: graphql_query }" }

      it_behaves_like 'code that registers an offense'
    end

    context 'when not using params' do
      let(:code) { "RSpec.describe 'GraphQL' do post graphql_path end" }

      it_behaves_like 'code that does not register an offense'
    end

    context 'when not using params without hash value' do
      let(:code) { "RSpec.describe 'GraphQL' do post graphql_path, params: the_params end" }

      it_behaves_like 'code that does not register an offense'
    end
  end

  context 'outside RSpec blocks' do
    context 'with query' do
      let(:code) { "post '/graphql', params: { query: graphql_query }" }

      it_behaves_like 'code that does not register an offense'
    end

    context 'without query' do
      let(:code) { "post '/graphql'" }

      it_behaves_like 'code that does not register an offense'
    end
  end

  context 'when using helper method (make_graphql_request)' do
    context 'within RSpec blocks' do
      context 'with query and variables' do
        let(:code) do
          "RSpec.describe 'GraphQL' do make_graphql_request(query: graphql_query, variables: graphql_variables) end"
        end

        it_behaves_like 'code that does not register an offense'
      end

      context 'without query' do
        let(:code) { "RSpec.describe 'GraphQL' do make_graphql_request end" }

        it_behaves_like 'code that does not register an offense'
      end
    end

    context 'outside RSpec blocks' do
      context 'with query and variables' do
        let(:code) { 'make_graphql_request(query: graphql_query, variables: graphql_variables)' }

        it_behaves_like 'code that does not register an offense'
      end

      context 'without query' do
        let(:code) { 'make_graphql_request' }

        it_behaves_like 'code that does not register an offense'
      end
    end
  end
end
