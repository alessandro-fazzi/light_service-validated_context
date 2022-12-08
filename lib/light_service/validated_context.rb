# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.new
loader.tag = 'LightService::I18n'
loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
loader.push_dir(__dir__, :namespace => LightService)
loader.setup

require 'light-service'
require 'dry-types'

module LightService
  module ValidatedContext; end
end

module LightService
  class Context
    ValidatedKey = LightService::ValidatedContext::ValidatedKey
    FailOnValidationError = LightService::ValidatedContext::FailOnValidationError
    prepend LightService::ValidatedContext::Context

    class KeyVerifier
      prepend LightService::ValidatedContext::KeyVerifier
    end

    class ExpectedKeyVerifier
      prepend LightService::ValidatedContext::ExpectedKeyVerifier
    end

    class PromisedKeyVerifier
      prepend LightService::ValidatedContext::PromisedKeyVerifier
    end
  end

  module Types
    include Dry.Types()
  end
end

# Convenience alias for implementor
Types = LightService::Types unless Module.const_defined?('Types')

# Convenience alias for implementor
ValidatedKey = LightService::Context::ValidatedKey unless Module.const_defined?('ValidatedKey')
VK = LightService::Context::ValidatedKey unless Module.const_defined?('VK')
