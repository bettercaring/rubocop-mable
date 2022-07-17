# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/mable'
require_relative 'rubocop/mable/version'
require_relative 'rubocop/mable/inject'

RuboCop::Mable::Inject.defaults!

require_relative 'rubocop/cop/mable_cops'
