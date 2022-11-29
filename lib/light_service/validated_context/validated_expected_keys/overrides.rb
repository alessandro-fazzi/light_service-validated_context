# frozen_string_literal: true

module LightService
  module ValidatedContext
    module ValidatedExpectedKeys
      module Overrides
        def keys
          action.expected_keys.map do |key|
            next key unless key.is_a?(ValidatedKey)

            key.label
          end
        end

        def raw_keys
          action.expected_keys
        end
      end
    end
  end
end
