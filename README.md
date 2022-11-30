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
type-check, coerce and describe action's arguments without reinventing the wheel (the wheel we use under the wood is [`dry-types`](https://dry-rb.org/gems/dry-types))
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

```ruby
class ActionOne
  extend LightService::Action

  expects VK.new(:email, Types::Strict::String)
  expects VK.new(:age, Types::Coercible::Integer.constrained(gt: 30))
  expects VK.new(:ary, Types::Array.of(Types::Strict::Symbol).constrained(min_size: 1))
  promises VK.new(:text, Types::Strict::String.constrained(max_size: 10).default('foobar'))

  executed do |context|
    # something happens
  end
end

result = ActionOne.execute(email: 'foo@example.com', age: '37', ary: [:foo])
# => {:email=>"foo@example.com", :age=>37, :ary=>[:foo], :text=>"foobar"}
result = ActionOne.execute(age: '37', ary: [:foo])
# expected :email to be in the context during ActionOne (LightService::ExpectedKeysNotInContextError)
result = ActionOne.execute(email: 'foo@example.com', age: '37', ary: [])
# [] violates constraints (min_size?(1, []) failed) (LightService::ExpectedKeysNotInContextError)
```

Since all the validation and coercion logic is delegated to `dry-types`, you can
read more about what you can achieve at https://dry-rb.org/gems/dry-types/1.2/

`VK` objects needs to be created with 2 positional arguments:

- key name as a symbol
- A type

`VK` and `ValidatedKey` (equivalent) are short aliases for `LightService::Context::ValidatedKey`.
They are created only if not already defined in the global space. You're free to use the namespaced
form to avoid name collisions.

You can find more usage example in `spec/support/test_doubles.rb`

## Why validation matters?

In OO programming there's a rule (strict or "of thumb", IDK) that says to "never" instantiate an
invalid object whenever the object self has the concept of _validity_ for itself. This rule takes
sense to my eyes whenever I'm working with an object already initialized and in memory, but I cannot
trust its internal status.

Taken that `light-service` doesn't work on instances, but it works on classes and class methods
having a more functional and stateless approach, side effects of having invalid state in the context
(which is The state of an Action/Organizer) are mostly the same.

Rewording: if I cannot trust the state, given
the state is internal or delegated to a context object, I'll have to to a bunch of validation-oriented
logical branches into my logic. E.g.:

```ruby
class HugAFriend
  extend LightService::Action

  expects :friend

  executed do |context|
    context.friend.hug if context.friend.respond_to?(:hug)
  end
end
```

The `if` in this uber-trivial example exists just due to lack of trust on the state.

Let's re-imagine the code given an `executed` block that totally trusts the context:


```ruby
class HugAFriend
  extend LightService::Action

  expects VK.new(:friend, Types.Instance(Friend))
  # Or a less usual approach could be to trust duck typing
  # expects VK.new(:friend, Types::Interface(:hug))

  executed do |context|
    context.friend.hug
  end
end
```

## Comparison with similar gems

This is a comparison table I've done using my own limited experience w/ other solutions
and/or reading projects' READMEs. Don't take my word for it. And if I was wrong understanding
some features, feel free to drop me a line on Mastodon [@alessandrofazzi@mastodon.uno](https://mastodon.uno/@alessandrofazzi)

| Feature                   | adomokos/light-service | sunny/actor                                          | collectiveidea/interactor | AaronLasseigne/active_interaction | pioneerskies/light_service-validated_context/ |
| ------------------------- | ---------------------- | ---------------------------------------------------- | ------------------------- | --------------------------------- | --------------------------------------------- |
| presence                  | ✅                      | ✅                                                    | ❌                         | ⚠️ Only input, not output   | ✅                                             |
| static default            | ✅                      | ✅                                                    | ❌                         | ✅                                 | ✅                                             |
| dynamic default           | ✅                      | ✅                                                    | ❌                         | ✅                                 | ✅                                             |
| raise or fail control     | ❌                      | ✅                                                    | ❌                         | ❓                                 | ❌                                             |
| type check                | ❌                      | ✅                                                    | ❌                         | ✅                                 | ✅                                             |
| data structure type check | ❌                      | ❌                                                    | ❌                         | ❌                                 | ✅                                             |
| optional                  | ⚠️ through `default`    | ✅ through `allow_nil` (which defaults to `true` 🤔 ❓) | ❌                         | ⚠️ through `default`               | ✅                                             |
| built-in                  | ✅                      | ✅                                                     | ❌                         | ❌ ActiveModel::Validation        | ❌ Dry::Types                                  |


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pioneerskies/light_service-validated_context. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pioneerskies/light_service-validated_context/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LightService::ValidatedContext project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pioneerskies/light_service-validated_context/blob/main/CODE_OF_CONDUCT.md).
