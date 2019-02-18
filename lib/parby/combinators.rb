require 'parby/parser'

module Parby
  # Always yields the value passed to it, no matter the input
  def self.of(value)
    Parser.new { |input, index| Success.new(index, value, input) }
  end

  # Yields the first character that matches predicate, it fails with the given message, otherwise a generic one
  def self.test(predicate, description = nil)
    Parser.new do |input, index|
      found = nil
      input.split('').each do |character|
        if predicate.call(character)
          found = character
          break
        end
      end

      if found
        Success.new(index, found, input)
      else
        Failure.new(index, [description || 'Matching a predicate'], input)
      end
    end
  end

  # Yields the input, if it matches the regex passed to it
  def self.regexp(regex)
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

  def self.regex(regex)
    return self.regexp(regex)
  end

  # Searches in the input for one of the given characters (characters can be either a string or an array), and yields it
  def self.one_of(characters)
    expected = if characters.is_a?(Array) then characters else characters.split('') end
    test(Proc.new { |c| expected.include?(c) }, expected)
  end

  def self.none_of(characters)
    test(Proc.new { |c| !characters.include?(c) }, ["None of #{characters}"])
  end

  def self.string(str)
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

  def self.all
    Parser.new do |input, index|
      Success.new(index, input, nil)
    end
  end
end
