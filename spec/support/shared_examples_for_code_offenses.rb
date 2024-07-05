require 'spec_helper'

RSpec.shared_examples 'code that registers an offense' do
  it 'registers an offense' do
    spacer_start = 0
    caret_length = code.size

    if respond_to?(:offense_method)
      caret_length = offense_method.size
      spacer_start = code.index(offense_method)
    end

    expect_offense(
      <<~RUBY
        #{code}
        #{' ' * spacer_start}#{'^' * caret_length} #{cop.name}: #{offense_msg}
      RUBY
    )
  end
end

RSpec.shared_examples 'code that does not register an offense' do
  it 'does not register an offense' do
    expect_no_offenses(
      <<~RUBY
        #{code}
      RUBY
    )
  end
end
