require "spec_helper"

RSpec.shared_examples 'code that registers an offense' do
  it 'registers an offense' do
    expect_offense(
    <<~RUBY
        #{code}
        #{'^' * code.length} #{offense_msg}
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
