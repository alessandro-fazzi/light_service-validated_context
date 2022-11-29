# frozen_string_literal: true

module LightService
  module ValidatedContext
    module ValidatedPromisedKeys
      module Overrides
        def keys
          action.promised_keys.map do |key|
            next key unless key.is_a?(ValidatedKey)

            key.label
          end
        end

        def raw_keys
          action.promised_keys
        end
      end
    end
  end
end
