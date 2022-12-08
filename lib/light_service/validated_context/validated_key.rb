# frozen_string_literal: true

module LightService
  module ValidatedContext
    class ValidatedKey
      attr_reader :label, :type, :message

      def initialize(label, type, message: nil)
        @label = label
        @type = type
        @message = message
      end

      def to_sym
        label.to_sym
      end

      def to_s
        label.to_s
      end
    end
  end
end
