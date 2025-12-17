# frozen_string_literal: true

# This cop enforces that each task in a Rake file has an annotation block directly above it.
#
# Example:
#   # Task: example:my_task
#   #   Type: one-off
#   #   Created: 2025-01-15
#   #   Ownership: @bettercaring/payments
#   #   Cleanup Card: ES-123
#   #   Cleanup Date: 2025-07-15
#   task :my_task do
#   end

module RuboCop
  module Cop
    module Mable
      class RequiredTaskHeader < Base
        module Messages
          EXAMPLE_WITH_CLEANUP = <<~EXAMPLE.strip
            # Task: task_name
            #   Type: one-off
            #   Created: 2025-01-15
            #   Ownership: @bettercaring/payments
            #   Cleanup Card: ES-123
            #   Cleanup Date: 2025-07-15
          EXAMPLE

          EXAMPLE_WITHOUT_CLEANUP = <<~EXAMPLE.strip
            # Task: task_name
            #   Type: operational
            #   Created: 2025-01-15
            #   Ownership: @bettercaring/payments
          EXAMPLE

          MSG_MISSING_ANNOTATION = "Task '%<task>s' is defined but does not have an annotation block above it. " \
                                   "Example (temporary task):\n#{EXAMPLE_WITH_CLEANUP}\n" \
                                   "Example (indefinite task):\n#{EXAMPLE_WITHOUT_CLEANUP}"
          MSG_TASK_NAME_MISMATCH = "Task annotation name '%<annotation_name>s' does not match task name '%<task_name>s'. " \
                                   "Example:\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_MISSING_TYPE = "Task '%<task>s' is missing 'Type' field in its annotation block. " \
                             "Example:\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_INVALID_TYPE = "Task '%<task>s' has invalid Type. Must be 'one-off' or 'operational'. " \
                             "Example:\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_MISSING_CREATED = "Task '%<task>s' is missing 'Created' date in its annotation block. " \
                                "Example:\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_INVALID_CREATED = "Task '%<task>s' has invalid Created date. Must be in YYYY-MM-DD format. " \
                                "Example:\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_MISSING_CLEANUP_CARD = "Task '%<task>s' is missing 'Cleanup Card' field in its annotation block. " \
                                     "Example (temporary task with cleanup date):\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_MISSING_CLEANUP_DATE = "Task '%<task>s' is missing 'Cleanup Date' field in its annotation block. " \
                                     "Example (temporary task with cleanup date):\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_INVALID_CLEANUP_DATE = "Task '%<task>s' has invalid Cleanup Date. Must be YYYY-MM-DD or 'Operational'. " \
                                      "Example (temporary task):\n#{EXAMPLE_WITH_CLEANUP}\n" \
                                      "Example (indefinite task):\n#{EXAMPLE_WITHOUT_CLEANUP}"
          MSG_INVALID_CLEANUP_CARD = "Task '%<task>s' has invalid Cleanup Card. For 'one-off' tasks, it cannot be 'Operational'. " \
                                     "Example:\n#{EXAMPLE_WITH_CLEANUP}"
          MSG_CLEANUP_DATE_PASSED = "Task '%<task>s' should have been cleaned up after %<cleanup_date>s. " \
                                    "The cleanup date has passed. Please remove the task or update the cleanup date."
          MSG_MISSING_OWNERSHIP = "Task '%<task>s' is missing 'Ownership' field in its annotation block. " \
                                  "Example:\n#{EXAMPLE_WITH_CLEANUP}"
        end

        EXCLUDED_FILES = %w[
          cucumber.rake
          annotate_rb.rake
        ].freeze

        RESTRICT_ON_SEND = %i[task].freeze

        # Require modules after Messages is defined
        require_relative 'task_extractor'
        require_relative 'annotation_parser'
        require_relative 'validation_rules'
        require_relative 'annotation_validator'

        def on_new_investigation
          file_path = processed_source.file_path
          return unless file_path.end_with?('.rake')
          return if EXCLUDED_FILES.any? { |excluded| file_path.include?(excluded) }

          tasks_data = TaskExtractor.collect_all_tasks(processed_source)
          return unless tasks_data.any?

          tasks_data.each do |full_task_name, node|
            check_task_annotation(node, full_task_name)
          end
        end

        private

        def check_task_annotation(node, full_task_name)
          annotation_block = AnnotationParser.find_annotation_block_for_task(node, processed_source)

          unless annotation_block
            add_offense(
              node,
              message: format(Messages::MSG_MISSING_ANNOTATION, task: full_task_name)
            )
            return
          end

          annotation = AnnotationParser.parse_annotation_block(annotation_block)
          AnnotationValidator.validate(node, full_task_name, annotation, self)
        end
      end
    end
  end
end
