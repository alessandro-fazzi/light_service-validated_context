# frozen_string_literal: true

module ValidatedContext
  module KeyVerifier
    def type_check_and_coerce_keys!(keys)
      errors = []

      keys.each do |key|
        next unless key.is_a?(LightService::Context::ValidatedKey)

        begin
          context[key.label] = key.type[context[key.label] || Dry::Types::Undefined]
        rescue Dry::Types::CoercionError => e
          errors << "[#{action}][:#{key.label}] #{e.message}"
        end
      end
      # debugger
      @validation_errors = errors
    end

    def are_all_keys_valid?
      @validation_errors.none?
    end

    def error_message
      @validation_errors.join(', ')
    end
  end
end
