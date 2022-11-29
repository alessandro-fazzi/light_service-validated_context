# frozen_string_literal: true

require_relative "lib/light_service/validated_context/version"

Gem::Specification.new do |spec|
  spec.name = "light_service-validated_context"
  spec.version = LightService::ValidatedContext::VERSION
  spec.authors = ["'Alessandro Fazzi'"]
  spec.email = ["alessandro.fazzi@welaika.com"]

  spec.summary = "Write a short summary, because RubyGems requires one."
  # spec.description = "TODO: Write a longer description or delete this line."
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # rubocop:disable Layout/LineLength
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|github|solargraph|rspec|vscode)|appveyor)})
    end
  end
  # rubocop:enable Layout/LineLength

  # spec.bindir = "exe"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "dry-types", "~> 1.7.0"
  spec.add_dependency "light-service", ">= 0.18.0"
  spec.add_dependency "zeitwerk"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
