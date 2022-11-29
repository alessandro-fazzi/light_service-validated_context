# frozen_string_literal: true

module LightService
  module ValidatedContext
    module Overrides
      def define_accessor_methods_for_keys(keys)
        super keys.map(&:label)
      end
    end
  end
end
