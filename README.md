# LightService - ValidatedContext

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

## Usage

```ruby
class ActionOne
  extend LightService::Action

  expects VK.(:email, Types::Strict::String)
  expects VK.(:age, Types::Coercible::Integer.constrained(gt: 30))
  expects VK.(:ary, Types::Array.of(Types::Strict::Symbol).constrained(min_size: 1))
  promises VK.(:text, Types::Strict::String.constrained(max_size: 10).default('foobar'))

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pioneerskies/light_service-validated_context. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pioneerskies/light_service-validated_context/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LightService::ValidatedContext project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pioneerskies/light_service-validated_context/blob/main/CODE_OF_CONDUCT.md).
