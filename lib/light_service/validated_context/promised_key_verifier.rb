# frozen_string_literal: true

module ValidatedContext
  module PromisedKeyVerifier
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
end
