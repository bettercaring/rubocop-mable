# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Mable::NoWardenInGraphQL, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  let(:offense_msg_test_mode) do
    'Do not use `test_mode!` in GraphQL specs. Use graphql helper method instead.'
  end
  let(:offense_msg_login_as) do
    'Do not use `login_as` in GraphQL specs. Use graphql helper method instead.'
  end
  let(:offense_msg_reload) do
    'Do not use `reload` in GraphQL specs. Use graphql helper method instead.'
  end
  let(:offense_msg_include) do
    'Do not use `include Warden::Test::Helpers` in GraphQL specs. Use graphql helper method instead.'
  end

  context 'when using Warden.test_mode! in GraphQL specs' do
    let(:offense_method) { 'Warden.test_mode!' }
    let(:code) { "RSpec.describe Graphql::Query do #{offense_method} end" }
    let(:offense_msg) { offense_msg_test_mode }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using login_as in GraphQL specs' do
    let(:offense_method) { 'login_as(user)' }
    let(:code) { "RSpec.describe Graphql::Query do #{offense_method} end" }
    let(:offense_msg) { offense_msg_login_as }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using user.reload in GraphQL specs' do
    let(:offense_method) { 'user.reload' }
    let(:code) { "RSpec.describe Graphql::Query do #{offense_method} end" }
    let(:offense_msg) { offense_msg_reload }

    it_behaves_like 'code that registers an offense'
  end

  context 'when including Warden::Test::Helpers in GraphQL specs' do
    let(:offense_method) { 'Warden::Test::Helpers' }
    let(:code) { "RSpec.describe Graphql::Query do include #{offense_method} end" }
    let(:offense_msg) { offense_msg_include }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using Warden.test_mode! in Queries specs' do
    let(:offense_method) { 'Warden.test_mode!' }
    let(:code) { "RSpec.describe Queries::UserDraft, type: :request do #{offense_method} end" }
    let(:offense_msg) { offense_msg_test_mode }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using login_as in Queries specs' do
    let(:offense_method) { 'login_as(user)' }
    let(:code) { "RSpec.describe Queries::UserDraft, type: :request do #{offense_method} end" }
    let(:offense_msg) { offense_msg_login_as }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using user.reload in Queries specs' do
    let(:offense_method) { 'user.reload' }
    let(:code) { "RSpec.describe Queries::UserDraft, type: :request do #{offense_method} end" }
    let(:offense_msg) { offense_msg_reload }

    it_behaves_like 'code that registers an offense'
  end

  context 'when including Warden::Test::Helpers in Queries specs' do
    let(:offense_method) { 'Warden::Test::Helpers' }
    let(:code) { "RSpec.describe Queries::UserDraft, type: :request do include #{offense_method} end" }
    let(:offense_msg) { offense_msg_include }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using Warden.test_mode! in Mutations specs' do
    let(:offense_method) { 'Warden.test_mode!' }
    let(:code) { "RSpec.describe Mutations::CreateUser, type: :request do #{offense_method} end" }
    let(:offense_msg) { offense_msg_test_mode }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using login_as in Mutations specs' do
    let(:offense_method) { 'login_as(user)' }
    let(:code) { "RSpec.describe Mutations::CreateUser, type: :request do #{offense_method} end" }
    let(:offense_msg) { offense_msg_login_as }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using user.reload in Mutations specs' do
    let(:offense_method) { 'user.reload' }
    let(:code) { "RSpec.describe Mutations::CreateUser, type: :request do #{offense_method} end" }
    let(:offense_msg) { offense_msg_reload }

    it_behaves_like 'code that registers an offense'
  end

  context 'when including Warden::Test::Helpers in Mutations specs' do
    let(:offense_method) { 'Warden::Test::Helpers' }
    let(:code) { "RSpec.describe Mutations::CreateUser, type: :request do include #{offense_method} end" }
    let(:offense_msg) { offense_msg_include }

    it_behaves_like 'code that registers an offense'
  end

  context 'when not using restricted offense_methods in GraphQL, Queries, Mutations, or request specs' do
    let(:offense_method) { 'some_other_offense_method' }
    let(:code) { "RSpec.describe Graphql::Query do #{offense_method} end" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'when not using restricted offense_methods in Queries specs' do
    let(:offense_method) { 'some_other_offense_method' }
    let(:code) { "RSpec.describe Queries::UserDraft, type: :request do #{offense_method} end" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'when not using restricted offense_methods in Mutations specs' do
    let(:offense_method) { 'some_other_offense_method' }
    let(:code) { "RSpec.describe Mutations::CreateUser, type: :request do #{offense_method} end" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'when not using restricted offense_methods in other request specs' do
    let(:offense_method) { 'some_other_offense_method' }
    let(:code) { "RSpec.describe 'SomeOtherType', type: :request do #{offense_method} end" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'outside RSpec GraphQL, Queries, Mutations, or request blocks' do
    let(:offense_method) { 'Warden.test_mode!' }
    let(:code) { "#{offense_method}" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'outside RSpec GraphQL, Queries, Mutations, or request blocks' do
    let(:offense_method) { 'login_as(user)' }
    let(:code) { "#{offense_method}" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'outside RSpec GraphQL, Queries, Mutations, or request blocks' do
    let(:offense_method) { 'user.reload' }
    let(:code) { "#{offense_method}" }

    it_behaves_like 'code that does not register an offense'
  end

  context 'outside RSpec GraphQL, Queries, Mutations, or request blocks' do
    let(:offense_method) { 'include Warden::Test::Helpers' }
    let(:code) { "#{offense_method}" }

    it_behaves_like 'code that does not register an offense'
  end
end
