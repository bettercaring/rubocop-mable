require 'spec_helper'

RSpec.shared_examples 'code that registers an offense' do
  it 'registers an offense' do
    spacer_start = 0
    caret_length = code.size

    if respond_to?(:offense_method)
      caret_length = offense_method.size
      spacer_start = code.index(offense_method)
    end

    expect_offense(<<~RUBY)
      #{code}
      #{' ' * spacer_start}#{'^' * caret_length} #{cop.name}: #{offense_msg}
    RUBY

    if respond_to?(:correction)
      start_index = code.index(offense_method)
      end_index = start_index + offense_method.size

      perm_start = code[0..start_index - 1]
      perm_end = code[end_index..]

      expect_correction(<<~RUBY)
        #{perm_start}#{correction}#{perm_end}
      RUBY
    end
  end
end

RSpec.shared_examples 'code that does not register an offense' do
  it 'does not register an offense' do
    expect_no_offenses(<<~RUBY)
      #{code}
    RUBY
  end
end
