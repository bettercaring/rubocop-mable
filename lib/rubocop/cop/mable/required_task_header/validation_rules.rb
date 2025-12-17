# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      class RequiredTaskHeader
        # Validation rules configuration for annotation fields
        module ValidationRules
          # NOTE: Validators that use valid_date_format? will be evaluated at runtime
          # when AnnotationValidator is fully loaded, avoiding circular dependency issues
          VALIDATION_RULES = {
            type: {
              required: true,
              validator: ->(value) { %w[one-off operational].include?(value) },
              missing_msg: RequiredTaskHeader::Messages::MSG_MISSING_TYPE,
              invalid_msg: RequiredTaskHeader::Messages::MSG_INVALID_TYPE
            },
            created: {
              required: true,
              validator: ->(value) { RequiredTaskHeader::AnnotationValidator.valid_date_format?(value) },
              missing_msg: RequiredTaskHeader::Messages::MSG_MISSING_CREATED,
              invalid_msg: RequiredTaskHeader::Messages::MSG_INVALID_CREATED
            },
            ownership: {
              required: true,
              missing_msg: RequiredTaskHeader::Messages::MSG_MISSING_OWNERSHIP
            },
            cleanup_card: {
              required: false, # Conditionally required based on task type
              missing_msg: RequiredTaskHeader::Messages::MSG_MISSING_CLEANUP_CARD
            },
            cleanup_date: {
              required: false, # Conditionally required based on task type
              validator: lambda do |value|
                value == 'Operational' || RequiredTaskHeader::AnnotationValidator.valid_date_format?(value)
              end,
              missing_msg: RequiredTaskHeader::Messages::MSG_MISSING_CLEANUP_DATE,
              invalid_msg: RequiredTaskHeader::Messages::MSG_INVALID_CLEANUP_DATE
            }
          }.freeze
        end
      end
    end
  end
end
