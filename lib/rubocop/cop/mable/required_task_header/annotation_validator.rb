# frozen_string_literal: true

require 'date'

module RuboCop
  module Cop
    module Mable
      class RequiredTaskHeader
        module AnnotationValidator
          def self.validate(node, full_task_name, annotation, cop)
            validate_task_name_match(node, full_task_name, annotation, cop)
            validate_fields(node, full_task_name, annotation, cop)
          end

          def self.validate_task_name_match(node, full_task_name, annotation, cop)
            return unless annotation[:task_name] && annotation[:task_name] != full_task_name

            cop.add_offense(
              node,
              message: format(RequiredTaskHeader::Messages::MSG_TASK_NAME_MISMATCH,
                              annotation_name: annotation[:task_name],
                              task_name: full_task_name)
            )
          end

          def self.validate_fields(node, full_task_name, annotation, cop)
            context = { node: node, full_task_name: full_task_name, cop: cop, annotation: annotation }
            ValidationRules::VALIDATION_RULES.each do |field, rules|
              value = annotation[field]
              next if validate_field(context, field, value, rules)
            end
            validate_cleanup_fields_for_type(context, annotation)
          end

          def self.validate_field(context, field, value, rules)
            return true if check_missing_field(context, value, rules)
            return true if skip_validation?(field, value)

            check_field_validity(context, value, rules)
            check_cleanup_date_expiration(context, field, value)
            false
          end

          def self.check_missing_field(context, value, rules)
            return false unless rules[:required] && value.nil?

            context[:cop].add_offense(
              context[:node],
              message: format(rules[:missing_msg], task: context[:full_task_name])
            )
            true
          end

          def self.skip_validation?(field, value)
            value.nil? || (field == :cleanup_date && value == 'Operational')
          end

          def self.check_field_validity(context, value, rules)
            return unless rules[:validator] && !rules[:validator].call(value)

            context[:cop].add_offense(
              context[:node],
              message: format(rules[:invalid_msg], task: context[:full_task_name])
            )
          end

          def self.check_cleanup_date_expiration(context, field, value)
            return unless field == :cleanup_date && valid_date_format?(value)

            cleanup_date = Date.parse(value)
            return unless Date.today > cleanup_date

            context[:cop].add_offense(
              context[:node],
              message: format(RequiredTaskHeader::Messages::MSG_CLEANUP_DATE_PASSED,
                              task: context[:full_task_name],
                              cleanup_date: cleanup_date.strftime('%Y-%m-%d'))
            )
          end

          def self.validate_cleanup_fields_for_type(context, annotation)
            task_type = annotation[:type]
            return unless task_type

            if task_type == 'one-off'
              validate_one_off_cleanup_fields(context, annotation)
            elsif task_type == 'operational'
              validate_operational_cleanup_fields(context, annotation)
            end
          end

          def self.validate_one_off_cleanup_fields(context, annotation)
            cleanup_card = annotation[:cleanup_card]
            cleanup_date = annotation[:cleanup_date]

            # One-off tasks must have cleanup_card and cleanup_date, and they cannot be "Operational"
            if cleanup_card.nil? || (cleanup_card.is_a?(String) && cleanup_card.strip.empty?)
              context[:cop].add_offense(
                context[:node],
                message: format(RequiredTaskHeader::Messages::MSG_MISSING_CLEANUP_CARD,
                                task: context[:full_task_name])
              )
            elsif cleanup_card == 'Operational'
              context[:cop].add_offense(
                context[:node],
                message: format(RequiredTaskHeader::Messages::MSG_INVALID_CLEANUP_CARD,
                                task: context[:full_task_name])
              )
            end

            if cleanup_date.nil? || (cleanup_date.is_a?(String) && cleanup_date.strip.empty?)
              context[:cop].add_offense(
                context[:node],
                message: format(RequiredTaskHeader::Messages::MSG_MISSING_CLEANUP_DATE,
                                task: context[:full_task_name])
              )
            elsif cleanup_date == 'Operational'
              example = RequiredTaskHeader::Messages::EXAMPLE_WITH_CLEANUP
              context[:cop].add_offense(
                context[:node],
                message: format("Task '%<task>s' has invalid Cleanup Date. For 'one-off' tasks, it cannot be 'Operational'. " \
                                "Example:\n%<example>s",
                                task: context[:full_task_name],
                                example: example)
              )
            end
          end

          def self.validate_operational_cleanup_fields(context, annotation)
            cleanup_card = annotation[:cleanup_card]
            cleanup_date = annotation[:cleanup_date]

            # For operational tasks, cleanup_card and cleanup_date are optional
            # But if provided, they must be valid (either "Operational" or actual values)
            # If cleanup_card is provided and not "Operational", it must not be empty
            if cleanup_card && cleanup_card != 'Operational'
              if cleanup_card.is_a?(String) && cleanup_card.strip.empty?
                context[:cop].add_offense(
                  context[:node],
                  message: format("Task '%<task>s' has invalid Cleanup Card. Must be a card ID or 'Operational'. " \
                                  "Example (with cleanup):\n%<example_with>s\n" \
                                  "Example (without cleanup):\n%<example_without>s",
                                  task: context[:full_task_name],
                                  example_with: RequiredTaskHeader::Messages::EXAMPLE_WITH_CLEANUP,
                                  example_without: RequiredTaskHeader::Messages::EXAMPLE_WITHOUT_CLEANUP)
                )
              end
            end

            # If cleanup_date is provided and not "Operational", it must be a valid date
            if cleanup_date && cleanup_date != 'Operational'
              unless valid_date_format?(cleanup_date)
                context[:cop].add_offense(
                  context[:node],
                  message: format("Task '%<task>s' has invalid Cleanup Date. Must be YYYY-MM-DD or 'Operational'. " \
                                  "Example (with cleanup):\n%<example_with>s\n" \
                                  "Example (without cleanup):\n%<example_without>s",
                                  task: context[:full_task_name],
                                  example_with: RequiredTaskHeader::Messages::EXAMPLE_WITH_CLEANUP,
                                  example_without: RequiredTaskHeader::Messages::EXAMPLE_WITHOUT_CLEANUP)
                )
              end
            end
          end

          def self.valid_date_format?(date_str)
            return false unless date_str.match?(/^\d{4}-\d{2}-\d{2}$/)

            Date.parse(date_str)
            true
          rescue ArgumentError
            false
          end
        end
      end
    end
  end
end
