# frozen_string_literal: true

module ValidatedContext
  module FailOnValidationError
    def fail_on_validation_error? = true
    def throw_on_validation_error? = !fail_on_validation_error?
  end
end
