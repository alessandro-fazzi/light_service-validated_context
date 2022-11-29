# frozen_string_literal: true

module ValidatedContext
  module KeyVerifier
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
