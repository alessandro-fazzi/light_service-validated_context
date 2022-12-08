# frozen_string_literal: true

module LightService
  module ValidatedContext
    module ExpectedKeyVerifier
      def keys
        keys_as_symbols
      end

      def keys_as_symbols
        action.expected_keys.map do |key|
          next key unless key.is_a?(LightService::Context::ValidatedKey)

          key.to_sym
        end
      end

      def raw_keys
        action.expected_keys
      end

      def throw_error_predicate(_keys)
        type_check_and_coerce_keys!(raw_keys)

        return false if are_all_keys_valid?

        should_throw_on_validation_error?
      end
    end
  end
end
