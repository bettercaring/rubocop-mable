# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mable::UsingDeprecatedFFClient, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }
  # let(:correction) { 'FeatureFlags::Repo.get_feature_flag("test", { uuid: "fake-uuid" })' }

  let(:offense_msg) do
    'FeatureFlags::Client is deprecated, please use FeatureFlags::Repo'
  end

  context 'when using the deprecated client' do
    let(:code) { 'FeatureFlags::Client.get_feature_flag("test", { uuid: "fake-uuid" })' }

    it_behaves_like 'code that registers an offense'
  end

  context 'when using the current interface' do
    let(:code) { 'FeatureFlags::Repo.get_feature_flag("test", { uuid: "fake-uuid" })' }

    it_behaves_like 'code that does not register an offense'
  end
end
