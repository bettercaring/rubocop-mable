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
            context = { node: node, full_task_name: full_task_name, cop: cop }
            ValidationRules::VALIDATION_RULES.each do |field, rules|
              value = annotation[field]
              next if validate_field(context, field, value, rules)
            end
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
