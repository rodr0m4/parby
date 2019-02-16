module Convoy
  class Parser
    # { |input, index| } -> result
    def initialize(&block)
      if !block_given?
        raise ArgumentError.new('A bare parser must be initialized with a 1 or 2 argument block')
      end

      @block = block
    end

    def parse(*args)
      if args.length == 1
        @block.call(args[0], 0)
      else
        @block.call(args[0], args[1])
      end
    end

    def or another_parser
      Parser.new do |input, index|
        first = parse(input, index)

        if first.failed?
          another_parser.parse(input, index)
        else
          first
        end
      end
    end

    def | another_parser
      self.or another_parser
    end
  end

  Result = Struct.new("Result", :status, :index, :value, :furthest, :expected, :remaining) do
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
      actual_expected = expected if expected.kind_of?(Array) else [expected]
      super(false, -1, nil, furthest, actual_expected, remaining)
    end
  end

end
