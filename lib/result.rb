module Convoy
  Result = Struct.new('Result', :status, :index, :value, :furthest, :expected, :remaining) do
    def failed?
      !status
    end

    def succeed?
      status
    end

    def completed?
      remaining.nil?
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