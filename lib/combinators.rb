require 'parser'

module Convoy
  # Always yields the value passed to it, no matter the input
  def of(value)
    Parser.new { |_, index| Success.new(index, value) }
  end

  # Yields the input, if it matches the regex passed to it
  def regexp(regex)
    regexp_with_consume(regex, false)
  end

  # Like #regexp, but it consumes the input
  def cregexp(regex)
    regexp_with_consume(regex, true)
  end

  # Searches in the input for one of the given characters (characters can be either a string or an array), and yields it
  def one_of(characters)
    Parser.new do |input, index|
      expected = if characters.is_a?(Array) then characters else characters.split('') end

      found_index = expected.inject(nil) do |index_found, next_character|
        break index_found unless index_found.nil?

        input.index(next_character)
      end

      if found_index.nil?
        Failure.new(input.length, expected, input)
      else
        Success.new(index, input[found_index], input)
      end
    end
  end
end

# Non exposed Convoy combinators
module Convoy
  private

  # Yields the input, if it matches the regex passed to it, it consumes it if should_consume is true
  def regexp_with_consume(regex, should_consume)
    # We have to match from the beginning
    real_regex = /^#{regex}/

    Parser.new do |input, index|
      match_data = real_regex.match(input)

      if match_data.nil?
        # We did not even match one letter
        Failure.new(index, [regex], input)
      else
        remaining = if should_consume then match_data.post_match else input end
        # We did match, but there is still more to consume
        Success.new(index, match_data[0], remaining)
      end
    end
  end
end
