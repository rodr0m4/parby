require 'parser'

module Convoy
  def of value
    Parser.new { |_, index|
      Success.new(index, value)
    }
  end

  def regexp regex
    # We have to match from the beginning
    real_regex = /^#{regex}/

    Parser.new { |input, index|
      real_regex.match(input) { |match_data|
        if match_data == nil
          # We did not even match one letter
          Failure.new(index, regex, input)
        elsif match_data.post_match != nil
          # We did match, but there is still more to consume
          Success.new(index, match_data[0], match_data.post_match)
        else
          # We did consume the whole string
          Success.new(index, match_data[0], nil)
        end
      }
    }
  end
end
