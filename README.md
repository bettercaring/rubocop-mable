# Rubocop::Mable

Mable's custom Rubocop cops

## Cops

```

Mable/NoWardenInGraphQL:
  Description: "No Warden in graphQL use helper method instead see - Mable/NoPostInGraphQL"
  Enabled: true
  SafeAutoCorrect: false
  VersionAdded: "0.1.5"

Mable/NoPostInGraphQL:
Description: "Use graphQL helper method instead of use rails/rack request stack"
Enabled: true
VersionAdded: "0.1.4"
ReplacePostWith: "make_graphql_request"
SafeAutoCorrect: false
AllowedGraphQLPaths:
  - "/graphql"
  - " graphql_path"

Mable/NoSafetyAssured:
Description: 'An extra check to ensure that the safety_assured is required'
Enabled: true
VersionAdded: '0.1.3'

Mable/GraphQLHelperSpecs:
Description: 'Avoid hardcoding GraphQl path use helper instead.'
Enabled: true
VersionAdded: '0.1.2'

Mable/HardcodedDatabaseFactoryBotId:
Enabled: true
Description: 'Avoid hardcoding factory bot database IDs, instead, dynamically test for the ID'
VersionAdded: '0.1.1'

Mable/UsingDeprecatedFFClient:
  Description: "Using deprecated FeatureFlags::Client use FeatureFlags::Repo instead"
  Enabled: true
  SafeAutoCorrect: true
  VersionAdded: "0.1.8"
```

## TODO

- No interpolating SQL use santitize instead

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rubocop-mable --require=false

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rubocop-mable

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubocop-mable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rubocop-mable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubocop::Mable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rubocop-mable/blob/master/CODE_OF_CONDUCT.md).
