# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mable::NoSafetyAssured, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  context 'when registering an offense' do
    let(:offense_msg) do
      'Are you sure safety_assured is required, is there a better way? https://github.com/ankane/strong_migrations'
    end

    describe 'safety_assured' do
      let(:code) { 'safety_assured' }

      it_behaves_like 'code that registers an offense'
    end

    describe 'no safety_assured' do
      let(:code) { 'rename_column :model_name' }

      it_behaves_like 'code that does not register an offense'
    end
  end
end
