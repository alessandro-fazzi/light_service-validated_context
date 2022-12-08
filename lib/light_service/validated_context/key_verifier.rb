# frozen_string_literal: true

module LightService
  module ValidatedContext
    module KeyVerifier
      def initialize(context, action)
        @validation_errors = []

        super(context, action)
      end

      # rubocop:disable Metrics/AbcSize
      # Refactoring this is out of my scope ATM
      def type_check_and_coerce_keys!(keys)
        errors = []

        keys.each do |key|
          next unless key.is_a?(LightService::Context::ValidatedKey)

          begin
            context[key.label] = key.type[context[key.label] || Dry::Types::Undefined]
          rescue Dry::Types::CoercionError => e
            errors << (
              LightService::Configuration.localization_adapter.failure(key.message, action) ||
                "[#{action}][:#{key.label}] #{e.message}"
            )
          end
        end

        @validation_errors = errors
      end
      # rubocop:enable Metrics/AbcSize

      def are_all_keys_valid?
        @validation_errors.none?
      end

      def error_message
        @validation_errors.join(', ')
      end

      def should_throw_on_validation_error?
        return true unless action.respond_to?(:fail_on_validation_error?) && action.fail_on_validation_error?

        context.fail!(error_message)
        false
      end
    end
  end
end
