# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      # Ensures all OutboxEventsService subclasses are registered in the
      # VALID_CLASSES hash. A missing entry causes `OutboxEventsService.for`
      # to return nil, leading to a NoMethodError at runtime.
      #
      # This cop only runs on the file containing the VALID_CLASSES constant
      # inside the OutboxEventsService module.
      #
      # @example
      #   # bad - file app/services/outbox_events_service/foo_event.rb exists
      #   #       but is not in VALID_CLASSES
      #   VALID_CLASSES = {
      #     'BarEvent' => OutboxEventsService::BarEvent,
      #   }
      #
      #   # good - all event files are registered
      #   VALID_CLASSES = {
      #     'BarEvent' => OutboxEventsService::BarEvent,
      #     'FooEvent' => OutboxEventsService::FooEvent,
      #   }
      class OutboxEventNotRegistered < Base
        MSG = "OutboxEventsService class `%<class_name>s` (from `%<file_name>s`) is not registered in VALID_CLASSES."

        EXCLUDED_FILES = %w[base.rb base_client_event.rb].freeze

        def on_casgn(node)
          return unless node.name == :VALID_CLASSES
          return unless outbox_events_service_file?

          hash_node = node.children.last
          return unless hash_node&.hash_type?

          registered = extract_registered_classes(hash_node)
          unregistered = find_unregistered_event_files(registered)

          unregistered.each do |file_path, class_name|
            add_offense(hash_node, message: format(MSG, class_name: class_name, file_name: File.basename(file_path)))
          end
        end

        private

        def outbox_events_service_file?
          processed_source.file_path.end_with?("outbox_events_service.rb")
        end

        def extract_registered_classes(hash_node)
          hash_node.pairs.filter_map do |pair|
            const_node = pair.value
            const_to_string(const_node) if const_node.const_type?
          end.to_set
        end

        def const_to_string(node)
          parts = []
          current = node
          while current&.const_type?
            parts.unshift(current.children[1].to_s)
            current = current.children[0]
          end
          parts.join("::")
        end

        def find_unregistered_event_files(registered)
          event_dir = File.join(File.dirname(processed_source.file_path), "outbox_events_service")
          return [] unless File.directory?(event_dir)

          unregistered = []

          Dir.glob(File.join(event_dir, "**", "*.rb")).each do |file_path|
            basename = File.basename(file_path)
            next if EXCLUDED_FILES.include?(basename)

            class_name = derive_class_name(file_path, event_dir)
            unregistered << [file_path, class_name] unless registered.include?(class_name)
          end

          unregistered.sort_by(&:last)
        end

        def derive_class_name(file_path, event_dir)
          relative = file_path.delete_prefix("#{event_dir}/").delete_suffix(".rb")
          parts = relative.split("/")
          class_parts = parts.map { |part| part.split("_").map(&:capitalize).join }
          "OutboxEventsService::#{class_parts.join('::')}"
        end
      end
    end
  end
end
