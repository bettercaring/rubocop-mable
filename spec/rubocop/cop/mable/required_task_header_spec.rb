# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Mable::RequiredTaskHeader, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  context 'when file has no tasks' do
    let(:code) do
      <<~RUBY
        # frozen_string_literal: true
        # Some comment
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when task has no annotation block' do
    let(:code) do
      <<~RUBY
        # frozen_string_literal: true
        # Squad: @bettercaring/payments

        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for missing annotation' do
      expect_offense(<<~RUBY, 'test.rake')
        # frozen_string_literal: true
        # Squad: @bettercaring/payments

        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' is defined but does not have an annotation block above it
        end
      RUBY
    end
  end

  context 'when task has complete annotation block' do
    let(:code) do
      <<~RUBY
        # frozen_string_literal: true
        # Squad: @bettercaring/payments

        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when task annotation has name mismatch' do
    let(:code) do
      <<~RUBY
        # Task: wrong_name
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for name mismatch' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: wrong_name
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task annotation name 'wrong_name' does not match task name 'my_task'
        end
      RUBY
    end
  end

  context 'when task annotation is missing Type field' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for missing Type' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' is missing 'Type' field in its annotation block
        end
      RUBY
    end
  end

  context 'when task annotation has invalid Type' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: invalid
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for invalid Type' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: invalid
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' has invalid Type. Must be 'one-off' or 'operational'
        end
      RUBY
    end
  end

  context 'when task annotation is missing Created field' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for missing Created' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: operational
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' is missing 'Created' date in its annotation block
        end
      RUBY
    end
  end

  context 'when task annotation has invalid Created date' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: invalid-date
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for invalid Created date' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: operational
        #   Created: invalid-date
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' has invalid Created date. Must be in YYYY-MM-DD format
        end
      RUBY
    end
  end

  context 'when task annotation is missing Ownership field' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for missing Ownership' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' is missing 'Ownership' field in its annotation block
        end
      RUBY
    end
  end

  context 'when task annotation is missing Cleanup Card' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for missing Cleanup Card' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Date: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' is missing 'Cleanup Card' field in its annotation block
        end
      RUBY
    end
  end

  context 'when task annotation is missing Cleanup Date' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for missing Cleanup Date' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' is missing 'Cleanup Date' field in its annotation block
        end
      RUBY
    end
  end

  context 'when task annotation has invalid Cleanup Date' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: one-off
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: ES-123
        #   Cleanup Date: invalid-date
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for invalid Cleanup Date' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: one-off
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: ES-123
        #   Cleanup Date: invalid-date
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' has invalid Cleanup Date. Must be YYYY-MM-DD or 'Operational'
        end
      RUBY
    end
  end

  context 'when cleanup date has passed' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: one-off
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: ES-123
        #   Cleanup Date: 2020-01-01
        task :my_task do
        end
      RUBY
    end

    it 'registers an offense for expired cleanup date' do
      expect_offense(<<~RUBY, 'test.rake')
        # Task: my_task
        #   Type: one-off
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: ES-123
        #   Cleanup Date: 2020-01-01
        task :my_task do
        ^^^^^^^^^^^^^ Mable/RequiredTaskHeader: Task 'my_task' should have been cleaned up after 2020-01-01. The cleanup date has passed.
        end
      RUBY
    end
  end

  context 'when cleanup date has not passed' do
    let(:future_date) { (Date.today + 365).strftime('%Y-%m-%d') }
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: one-off
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: ES-123
        #   Cleanup Date: #{future_date}
        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when task is operational with Operational cleanup date' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when file has namespaced tasks' do
    let(:code) do
      <<~RUBY
        namespace :example do
          # Task: example:my_task
          #   Type: operational
          #   Created: 2025-01-15
          #   Ownership: @bettercaring/payments
          #   Cleanup Card: Operational
          #   Cleanup Date: Operational
          task :my_task do
          end
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when file has nested namespaces' do
    let(:code) do
      <<~RUBY
        namespace :ns1 do
          namespace :ns2 do
            # Task: ns1:ns2:my_task
            #   Type: operational
            #   Created: 2025-01-15
            #   Ownership: @bettercaring/payments
            #   Cleanup Card: Operational
            #   Cleanup Date: Operational
            task :my_task do
            end
          end
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when task uses string instead of symbol' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational
        task 'my_task' do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when file is excluded' do
    let(:code) do
      <<~RUBY
        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense for cucumber.rake' do
      expect_no_offenses(code, 'cucumber.rake')
    end

    it 'does not register an offense for annotate_rb.rake' do
      expect_no_offenses(code, 'annotate_rb.rake')
    end
  end

  context 'when file is not a .rake file' do
    let(:code) do
      <<~RUBY
        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rb')
    end
  end

  context 'when annotation block has blank lines before task' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: operational
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: Operational
        #   Cleanup Date: Operational

        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end

  context 'when task has one-off type with cleanup date' do
    let(:code) do
      <<~RUBY
        # Task: my_task
        #   Type: one-off
        #   Created: 2025-01-15
        #   Ownership: @bettercaring/payments
        #   Cleanup Card: ES-123
        #   Cleanup Date: 2025-12-31
        task :my_task do
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(code, 'test.rake')
    end
  end
end
