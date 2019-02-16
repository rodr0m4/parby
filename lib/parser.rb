module Convoy
  class Parser
    # { |input, index| } -> result or { |input| } -> result
    def initialize(&block)
      raise(ArgumentError, 'A bare parser must be initialized with a 1 or 2 argument block') unless block_given?

      @block = block
    end

    def parse(*args)
      if args.length == 1
        @block.call(args[0], 0)
      else
        @block.call(args[0], args[1])
      end
    end

    def or(another_parser)
      Parser.new do |input, index|
        first = parse(input, index)

        if first.failed?
          another_parser.parse(input, index)
        else
          first
        end
      end
    end

    def |(other)
      self.or other
    end

    def and(another_parser)
      Parser.new do |input, index|
        first = parse(input, index)

        if first.failed?
          first
        else
          another_parser.parse(first.remaining, first.index)
        end
      end
    end

    def >>(other)
      self.and other
    end

    def map(&block)
      Parser.new do |input, index|
        result = parse(input, index)

        if result.succeded?
          result.value = yield(result.value)
        end

        result
      end
    end
  end

  Result = Struct.new('Result', :status, :index, :value, :furthest, :expected, :remaining) do
    def failed?
      !status
    end

    def succeded?
      status
    end

    def completed?
      remaining == nil || remaining == ''
    end
  end

  class Success < Result
    def initialize(index, value, remaining = nil)
      super(true, index, value, -1, [], remaining)
    end
  end

  class Failure < Result
    def initialize(furthest, expected, remaining = nil)
      actual_expected = if expected.is_a?(Array) then expected else [expected] end
      super(false, -1, nil, furthest, actual_expected, remaining)
    end
  end
end
