module Parby
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

    def fmap(&block)
      Parser.new do |input, index|
        result = parse(input, index)

        if result.succeed?
          result.value = yield(result.value)
        end

        result
      end
    end

    def map(&block)
      fmap(&block)
    end

    def consuming
      self >> Parby.all
    end
  end
end
