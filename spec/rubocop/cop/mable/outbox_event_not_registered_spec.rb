# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mable::OutboxEventNotRegistered, :config do
  let(:config) { RuboCop::ConfigLoader.default_configuration }

  let(:event_dir) { "app/services/outbox_events_service" }

  before do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with(event_dir).and_return(true)
    allow(Dir).to receive(:glob).and_call_original
    allow(Dir).to receive(:glob).with(File.join(event_dir, "**", "*.rb")).and_return(event_files)
  end

  context "when all event classes are registered" do
    let(:event_files) do
      [
        "#{event_dir}/client_activated_event.rb",
        "#{event_dir}/client_signed_up_event.rb",
      ]
    end

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
            'ClientActivated' => OutboxEventsService::ClientActivatedEvent,
            'ClientSignedUp' => OutboxEventsService::ClientSignedUpEvent,
          }
        end
      RUBY
    end
  end

  context "when an event class is not registered" do
    let(:event_files) do
      [
        "#{event_dir}/client_activated_event.rb",
        "#{event_dir}/client_signed_up_event.rb",
        "#{event_dir}/client_service_agreement_activated.rb",
      ]
    end

    it "registers an offense for the missing class" do
      expect_offense(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
                          ^ Mable/OutboxEventNotRegistered: OutboxEventsService class `OutboxEventsService::ClientServiceAgreementActivated` (from `client_service_agreement_activated.rb`) is not registered in VALID_CLASSES.
            'ClientActivated' => OutboxEventsService::ClientActivatedEvent,
            'ClientSignedUp' => OutboxEventsService::ClientSignedUpEvent,
          }
        end
      RUBY
    end
  end

  context "when multiple event classes are not registered" do
    let(:event_files) do
      [
        "#{event_dir}/client_activated_event.rb",
        "#{event_dir}/foo_event.rb",
        "#{event_dir}/bar_event.rb",
      ]
    end

    it "registers an offense for the first missing class" do
      expect_offense(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
                          ^ Mable/OutboxEventNotRegistered: OutboxEventsService class `OutboxEventsService::BarEvent` (from `bar_event.rb`) is not registered in VALID_CLASSES.
            'ClientActivated' => OutboxEventsService::ClientActivatedEvent,
          }
        end
      RUBY
    end
  end

  context "when base files are present" do
    let(:event_files) do
      [
        "#{event_dir}/base.rb",
        "#{event_dir}/base_client_event.rb",
        "#{event_dir}/client_activated_event.rb",
      ]
    end

    it "excludes base files and does not register an offense" do
      expect_no_offenses(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
            'ClientActivated' => OutboxEventsService::ClientActivatedEvent,
          }
        end
      RUBY
    end
  end

  context "when event files are in a subdirectory" do
    let(:event_files) do
      [
        "#{event_dir}/client_activated_event.rb",
        "#{event_dir}/charges/charge_created_event.rb",
        "#{event_dir}/charges/charge_deleted_event.rb",
      ]
    end

    it "maps subdirectory files to nested class names" do
      expect_no_offenses(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
            'ClientActivated' => OutboxEventsService::ClientActivatedEvent,
            'ChargeCreated' => OutboxEventsService::Charges::ChargeCreatedEvent,
            'ChargeDeleted' => OutboxEventsService::Charges::ChargeDeletedEvent,
          }
        end
      RUBY
    end
  end

  context "when a subdirectory event class is not registered" do
    let(:event_files) do
      [
        "#{event_dir}/charges/charge_created_event.rb",
        "#{event_dir}/charges/charge_voided_event.rb",
      ]
    end

    it "registers an offense for the missing nested class" do
      expect_offense(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
                          ^ Mable/OutboxEventNotRegistered: OutboxEventsService class `OutboxEventsService::Charges::ChargeVoidedEvent` (from `charge_voided_event.rb`) is not registered in VALID_CLASSES.
            'ChargeCreated' => OutboxEventsService::Charges::ChargeCreatedEvent,
          }
        end
      RUBY
    end
  end

  context "when the event directory does not exist" do
    let(:event_files) { [] }

    before do
      allow(File).to receive(:directory?).with(event_dir).and_return(false)
    end

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "app/services/outbox_events_service.rb")
        module OutboxEventsService
          VALID_CLASSES = {
            'ClientActivated' => OutboxEventsService::ClientActivatedEvent,
          }
        end
      RUBY
    end
  end

  context "when VALID_CLASSES is in a different file" do
    let(:event_files) { [] }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "app/services/some_other_service.rb")
        module SomeOtherService
          VALID_CLASSES = {
            'Foo' => SomeOtherService::Foo,
          }
        end
      RUBY
    end
  end
end
