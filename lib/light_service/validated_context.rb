# frozen_string_literal: true

require 'light-service'
require 'dry-types'
require_relative "validated_context/version"

module LightService
  module ValidatedContext
    module ValidatedKeysContextOverrides
      def define_accessor_methods_for_keys(keys)
        super keys.map(&:to_sym)
      end
    end

    module ValidatedExpectedKeysOverrides
      def keys
        action.expected_keys.map do |key|
          next key unless key.is_a?(LightService::Context::ValidatedKey)

          key.label
        end
      end

      def raw_keys
        action.expected_keys
      end
    end

    module ValidatedPromisedKeysOverrides
      def keys
        action.promised_keys.map do |key|
          next key unless key.is_a?(LightService::Context::ValidatedKey)

          key.label
        end
      end

      def raw_keys
        action.promised_keys
      end
    end

    module ValidatedKeyVerifier
      def are_all_keys_valid?(validated_keys)
        errors = []

        validated_keys.each do |key|
          next unless key.is_a?(LightService::Context::ValidatedKey)

          begin
            context[key.label] = key.type[context[key.label] || Dry::Types::Undefined]
          rescue Dry::Types::CoercionError => e
            errors << e.message
          end
        end

        [errors.none?, errors]
      end

      def are_all_keys_in_context?(keys)
        keys_are_all_valid, validation_errors = are_all_keys_valid?(raw_keys)

        not_found_keys = keys_not_found(keys)
        keys_are_all_present = not_found_keys.none?

        return true if keys_are_all_valid && keys_are_all_present

        msg = if !keys_are_all_present
                error_message
              elsif !keys_are_all_valid
                validation_errors.join(', ')
              end

        LightService::Configuration.logger.error msg
        raise error_to_throw, msg
      end
    end
  end
end

module LightService
  class Context
    ValidatedKey = Struct.new(:label, :type) do
      def to_sym
        label.to_sym
      end

      def to_s
        label.to_s
      end
    end

    prepend LightService::ValidatedContext::ValidatedKeysContextOverrides

    class ExpectedKeyVerifier
      prepend LightService::ValidatedContext::ValidatedKeyVerifier
      prepend LightService::ValidatedContext::ValidatedExpectedKeysOverrides
    end

    class PromisedKeyVerifier
      prepend LightService::ValidatedContext::ValidatedKeyVerifier
      prepend LightService::ValidatedContext::ValidatedPromisedKeysOverrides
    end
  end
end

# Convenience namespace for implementor
module Types
  include Dry.Types()
end

# Convenience alias for implementor. Stands for "Validated Key".
VK = LightService::Context::ValidatedKey
