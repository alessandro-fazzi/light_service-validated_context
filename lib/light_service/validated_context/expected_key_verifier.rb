# frozen_string_literal: true

module ValidatedContext
  module ExpectedKeyVerifier
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
end
