# frozen_string_literal: true

module ValidatedContext
  module Context
    def define_accessor_methods_for_keys(keys)
      super keys.map(&:to_sym)
    end
  end
end
