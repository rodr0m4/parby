require 'parser'

module Convoy
  def of(value)
    Parser.new { |_, index| Success.new(index, value) }
  end

  def cregexp(regex)
    regexp_with_consume(regex, true)
  end

  def regexp(regex)
    regexp_with_consume(regex, false)
  end

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
