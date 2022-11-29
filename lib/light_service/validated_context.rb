# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require 'light-service'
require 'dry-types'

module ValidatedContext; end

module LightService
  class Context
    ValidatedKey = ::ValidatedContext::ValidatedKey
    prepend ::ValidatedContext::ContextOverrides

    class ExpectedKeyVerifier
      prepend ::ValidatedContext::KeyVerifier
      prepend ::ValidatedContext::ExpectedKeyVerifier
    end

    class PromisedKeyVerifier
      prepend ::ValidatedContext::KeyVerifier
      prepend ::ValidatedContext::PromisedKeyVerifier
    end
  end

  module Types
    include Dry.Types()
  end
end

# Convenience namespace for implementor
Types = LightService::Types unless Module.const_defined?('Types')

# Convenience alias for implementor
ValidatedKey = LightService::Context::ValidatedKey unless Module.const_defined?('ValidatedKey')
VK = LightService::Context::ValidatedKey unless Module.const_defined?('VK')
