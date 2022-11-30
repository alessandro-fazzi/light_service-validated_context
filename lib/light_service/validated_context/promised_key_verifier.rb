# frozen_string_literal: true

module ValidatedContext
  module PromisedKeyVerifier
    def keys
      keys_as_symbols
    end

    def keys_as_symbols
      raw_keys.map do |key|
        next key unless key.is_a?(LightService::Context::ValidatedKey)

        key.to_sym
      end
    end

    def raw_keys
      action.promised_keys
    end

    def throw_error_predicate(keys)
      type_check_and_coerce_keys!(raw_keys)

      keys_are_all_present = are_all_keys_in_context?(keys)

      return false if are_all_keys_valid? && keys_are_all_present

      true
    end
  end
end
