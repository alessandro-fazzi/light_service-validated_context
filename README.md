# LightService - ValidatedContext

[![Ruby](https://github.com/pioneerskies/light_service-validated_context/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/pioneerskies/light_service-validated_context/actions/workflows/main.yml)

This gem _patches_ `light-service` gem implementing validated keys
for `expects` and `promises` action's macros.

This gem is a plugin to `light-service`, thus it depends on it (~> 0.18.0).

## What do I mean with validation

- type check
- type coercion
- mandatory/optional presence
- default value

## Stability, affordability

This plugin uses monkey patching in order to alter the behaviour of `light-service`.
AFAIK this is the only way to achieve the goal. Because of this fact I consider
`light_service-validated_context` more of an experiment/POC.

## Goals

- implement an advanced and flexible interface to declare,
type-check, coerce and describe action's arguments without reinventing the wheel (the wheel we use under the wood is [`dry-types`](https://dry-rb.org/gems/dry-types/main/custom-types/))
- testing DX and interfaces
- study what parts of code are involved into this area of `light-service`'s code base

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'light_service-validated_context'
```

And then execute:

    $ bundle install

Would you need to manualy require the gem, here's the syntax:

```ruby
require 'light_service/validated_context'
```

## Usage

The plugin enables you to pass `VK` (`ValidatedKeys`) objects as arguments to built-ins `expects` and
`promises` macros.

This is how you'd usually write an `Action` in LightService:

```ruby
class ActionOne
  extend LightService::Action

  expects :age
  promises :text

  executed do |context|
    validate_age!(context)

    # Do something...

    context.text = 'Long live and prosperity'
  end

  def self.validate_age!(context)
    context.fail_and_return!(':age must be an Integer') unless context.age.is_a? Integer
    context.fail_and_return!('Sorry, you are too young m8') if (context.age <= 30)
  end
end
```

and this is how `light_service-validated_context` enables you to write

```ruby
class ActionOne
  extend LightService::Action

  expects VK.new(:age, Types::Coercible::Integer.constrained(gt: 30))
  promises VK.new(:text, Types::Strict::String.constrained(max_size: 10).default('Long live and prosperity'))

  executed do |context|
    # Do something
  end
end
```

and you'll get validations for free

```ruby
ActionOne.execute(age: '19')
# [App::ActionOne][:age] "19" violates constraints (gt?(30, 19) failed) (LightService::ExpectedKeysNotInContextError)
ActionOne.execute(age: 37)
# LightService::Context({:age=>37, :text=>"Long live and prosperity"}, success: true, message: '', error_code: nil, skip_remaining: false, aliases: {})
ActionOne.execute(age: 37, text: 'Too long too pass the constrain')
# [App::ActionOne][:text] "Too long too pass the constrain" violates constraints (max_size?(24, "Too long too pass the constrain") failed) (LightService::PromisedKeysNotInContextError)
```

Since all the validation and coercion logic is delegated to `dry-types`, you can
read more about what you can achieve at https://dry-rb.org/gems/dry-types/main/custom-types/

`VK` objects needs to be created with 2 positional arguments:

- key name as a symbol
- A type declaration from `dry-types` (`Tyeps` namespace is already setup for you)

`VK` and `ValidatedKey` (equivalent) are short aliases for `LightService::Context::ValidatedKey`.
They are created only if not already defined in the global space. You're free to use the namespaced
form to avoid name collisions.

You can find more usage example in `spec/support/test_doubles.rb`

### Custom validation error message

You can set a custom validation error message when instantiating a `VK` object

```ruby
VK.new(:my_integer, Types::Strict::Integer, message: 'Custom validation message for :my_integer key')
```

Messages translated via `I18n` are supported too, following standard `light-service`'s
[configuration](https://github.com/adomokos/light-service/#localizing-messages)

```ruby
VK.new(:my_integer, Types::Strict::Integer, message: :my_integer_error_message)
```

### Raise vs fail

By default, following original `light-service` implementation, a validation error will raise a
`LightService::ExpectedKeysNotInContextError` or `LightService::PromisedKeysNotInContextError`.

> NOTE: I know that raised exceptions do not express the concept of "invalid", but I opted
to preserve the original one in order to make this plugin more droppable-in as possible, thus
w/o breaking code relying on, for example, rescueing those specific excpetions.

May you prefere to fail the action, populating outcome's message with error message, just do
`extend LightService::Context::FailOnValidationError` into you action:

```ruby
class ActionFailInsteadOfRaise
  extend LightService::Action
  extend LightService::Context::FailOnValidationError

  expects VK.new(:foo, Types::String)

  executed do |context|
    # do something
  end
end

result = ActionFailInsteadOfRaise.execute(foo: 12)
result.message # Here you'll find the validation(s) message(s)
```

### Custom types

As documented in [dry-types doc](https://dry-rb.org/gems/dry-types/main/getting-started/#creating-your-first-type),
you can be more expressive defining custom types; you can define them reopening the already defined `LightService::Types` module
(or simply `Types` in the global namespace if it does not conflict with your domain's namespace), e.g.:

```ruby
module LightService::Types
  MyExpressiveThing = Hash.schema(
    name: String,
    age: Coercible::Integer,
    foo: Symbol.constrained(included_in: %i[bar baz])
  )
end

class ActionOne
  extend LightService::Action
  extend LightService::Context::FailOnValidationError

  expects VK.new(:foo, Types::MyBusinessHash)

  executed do |context|
    # do something...
  end
end

result = App::ActionOne.execute(foo: {
  name: 'Alessandro',
  age: '37',
  foo: :bar
})
```

Custom types will be reusable, more expressive and moreover will clean your action up a bit.

## Why validation matters?

In OO programming there's a rule that says to never instantiate an
invalid object.

If you cannot trust the state, given the state is internal or delegated to a context object,
you'll have to do a bunch of validation-oriented logical branches into your logic. E.g.:

```ruby
class HugAFriend
  extend LightService::Action

  expects :friend

  executed do |context|
    context.friend.hug if context.friend.respond_to?(:hug)
  end
end
```

The `if` in this uber-trivial example exists just due to untrusted state.

Let's re-imagine the code given an `executed` block that totally trusts the context:


```ruby
class HugAFriend
  extend LightService::Action

  expects VK.new(:friend, Types.Instance(Friend))
  # Or a less usual approach could be to trust duck typing
  # expects VK.new(:friend, Types::Interface(:hug))
  # Actually not all friends do appreciate hugs nor other forms of physical contact :P

  executed do |context|
    context.friend.hug
  end
end
```

## Comparison with similar gems

A brief comparison about what similar gems offer to work with validation.

This is a comparison table I've done using my own limited experience w/ other solutions
and/or reading projects' READMEs. Don't take my word for it. And if I was wrong understanding
some features, feel free to drop me a line on Mastodon [@alessandrofazzi@mastodon.uno](https://mastodon.uno/@alessandrofazzi)

| Feature                   | adomokos/light-service | sunny/actor                                          | collectiveidea/interactor | AaronLasseigne/active_interaction | pioneerskies/light_service-validated_context/ |
| ------------------------- | ---------------------- | ---------------------------------------------------- | ------------------------- | --------------------------------- | --------------------------------------------- |
| presence                  | ✅                      | ✅                                                    | ❌                         | ⚠️ Only input, not output   | ✅                                             |
| static default            | ✅                      | ✅                                                    | ❌                         | ✅                                 | ✅                                             |
| dynamic default           | ✅                      | ✅                                                    | ❌                         | ✅                                 | ✅                                             |
| raise or fail control     | ❌                      | ✅                                                    | ❌                         | ❓                                 | ✅                                             |
| type check                | ❌                      | ✅                                                    | ❌                         | ✅                                 | ✅                                             |
| data structure type check | ❌                      | ❌                                                    | ❌                         | ❌                                 | ✅                                             |
| optional                  | ⚠️ through `default`    | ✅ through `allow_nil` (which defaults to `true` 🤔 ❓) | ❌                         | ⚠️ through `default`               | ✅                                             |
| 1st party code                | ✅                      | ✅                                                     | ✅                         | ⚠️ ActiveModel::Validation        | ❌ Dry::Types                                  |

> NOTE: in `active_interaction` the fact that validation code isn't first party isn't an issue, since
> the gem is a Rails-only gem and validation is delegated to Rails, thus no additional dependencies
> are required. `light_service-validated_context` depends on additional gems from the dry-rb ecosystem

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pioneerskies/light_service-validated_context. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pioneerskies/light_service-validated_context/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LightService::ValidatedContext project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pioneerskies/light_service-validated_context/blob/main/CODE_OF_CONDUCT.md).
