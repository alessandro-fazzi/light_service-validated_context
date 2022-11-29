# frozen_string_literal: true

module LightService
  module ValidatedContext
    ValidatedKey = Struct.new(:label, :type) do
      def to_sym
        label.to_sym
      end

      def to_s
        label.to_s
      end
    end
  end
end
