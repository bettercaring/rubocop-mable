# frozen_string_literal: true

require_relative 'lib/rubocop/mable/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-mable'
  spec.version = RuboCop::Mable::VERSION
  spec.authors = ['Mable Engineers']
  spec.email = ['engineering@mable.com.au']

  spec.summary = "Mable's custom rubocop cops"
  spec.description = "Mable's custom rubocop cops"
  spec.homepage = 'https://github.com/rubocop-mable'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/bettercaring/rubocop-mable'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_runtime_dependency 'rubocop'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
