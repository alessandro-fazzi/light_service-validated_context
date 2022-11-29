# frozen_string_literal: true

class ActionExpectingStrictString
  extend LightService::Action

  expects VK.(:email, Types::Strict::String)

  executed do |context|
    context
  end
end

class ActionExpectingStrictStringWithDefault
  extend LightService::Action

  expects VK.(:email, Types::Strict::String.default('default@example.com'))

  executed do |context|
    context
  end
end

class ActionExpectingCoercibleString
  extend LightService::Action

  expects VK.(:email, Types::Coercible::String)

  executed do |context|
    context
  end
end

class ActionExpectingCoercibleInteger
  extend LightService::Action

  expects VK.(:number, Types::Coercible::Integer)

  executed do |context|
    context
  end
end

class ActionPromisingStrictString
  extend LightService::Action

  promises VK.(:email, Types::Strict::String)

  executed do |context|
    context.email = 'foo@email.com'
  end
end

class ActionPromisingStrictStringButItDoesNot
  extend LightService::Action

  promises VK.(:email, Types::Strict::String)

  executed do |context|
    context
  end
end

class ActionPromisingStrictStringWithDefault
  extend LightService::Action

  promises VK.(:email, Types::Strict::String.default('default@example.com'))

  executed do |context|
    context
  end
end

class ActionPromisingCoercibleString
  extend LightService::Action

  promises VK.(:email, Types::Coercible::String)

  executed do |context|
    context.email = :'symbol@example.com'
  end
end

class ActionPromisingCoercibleInteger
  extend LightService::Action

  promises VK.(:number, Types::Coercible::Integer)

  executed do |context|
    context.number = 'fourtytwo'
  end
end

class ActionPromisingCoercibleIntegerWithIgnoredConstain
  extend LightService::Action

  promises VK.(:number, Types::Coercible::Integer.constrained(:lteq => 40))

  executed do |context|
    context.number = '42'
  end
end

class CustomClass; end # rubocop:disable Lint/EmptyClass

class ActionExpectingCustomClass
  extend LightService::Action

  expects VK.(:klass, Types.Instance(::CustomClass))

  executed do |context|
    context
  end
end
