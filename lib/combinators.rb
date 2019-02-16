require 'parser'

module Convoy
  # Always yields the value passed to it, no matter the input
  def of(value)
    Parser.new { |input, index| Success.new(index, value, input) }
  end

  # Yields the input, if it matches the regex passed to it
  def regexp(regex)
    # We have to match from the beginning
    real_regex = /^#{regex}/

    Parser.new do |input, index|
      match_data = real_regex.match(input)

      if match_data.nil?
        # We did not even match one letter
        Failure.new(index, [regex], input)
      else
        Success.new(index, match_data[0], input)
      end
    end
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

  def string(str)
    Parser.new do |input, index|
      furthest = -1

      str.split('').each_with_index do |expected_character, expected_index|
        actual_character = input[expected_index]

        if actual_character.nil?
          # This means that the input is smaller than the expected string
          furthest = expected_index - 1
          break
        elsif actual_character != expected_character
          # This means the input does not match exactly the string
          furthest = expected_index
          break
        end
      end

      if furthest == -1
        Success.new(index, str)
      else
        Failure.new(furthest, [str])
      end
    end
  end

  def all
    Parser.new do |input, index|
      Success.new(index, input, nil)
    end
  end
end
