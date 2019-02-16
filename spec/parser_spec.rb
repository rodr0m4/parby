require 'spec_helper.rb'

include Convoy

describe Parser, "#init" do
  context 'not passing a block' do
    it 'raises' do
      expect {
        Parser.new(42)
      }.to raise_error(ArgumentError)
    end
  end

  context 'passing a block' do
    it 'initializes fine' do
      parser = Parser.new { |x| x }

      expect(parser).to be_a(Parser)
    end
  end
end

describe Parser, "#parse" do
  it 'just calls the proc' do
    parser = Parser.new { |_, _| 'Hello' }

    expect(parser.parse('some text')).to eq('Hello')
  end
end

describe Parser, '#|' do
  context 'Given two parsers' do
    parser = Convoy.regexp(/42/) | Convoy.of(42)

    it 'When the first one succeeds it yields, not calling the second one' do
      result = parser.parse('42')

      expect(result.succeed?).to be true
      expect(result.value).to eq('42')
    end

    it 'When the first one succeeds it calls the second one' do
      result = parser.parse('lol')

      expect(result.succeed?).to be true
      expect(result.value).to eq(42)
    end
  end
end

describe Parser, '#>>' do
  context 'Given two parsers' do
    first_parser = Convoy.regexp(/0/)

    it 'Both should have to match to succeed, but only the second value is yielded' do
      second_parser = Convoy.regexp(/[0-9]+/)
      parser = first_parser >> second_parser

      result = parser.parse('00')

      expect(result.succeed?).to be true
      expect(result.value).to eq('00')
    end

    it 'When the first one fails, the other one is not called' do
      second_parser = spy(Convoy.regexp(/[0-9]+/))
      parser = first_parser >> second_parser

      result = parser.parse('lol')

      expect(result.failed?).to be true
      expect(second_parser).to_not have_received(:parse)
    end
  end
end

describe Parser, '#map' do
  context('Given a parser mapped with a mapping block') do
    first_parser = Parser.regexp(/42/)
    parser = first_parser.map(&:to_i)

    it('when the parser yields, it will apply the block to the resulting value') do
      result = parser.parse('42')

      expect(result.succeed?).to be true
      expect(result.value).to eq(42)
    end

    # We still have to test for not calling the mapper function when the parser fails, but I can't mock the block :(
  end
end

describe Parser, '#consuming' do
  context 'any parser' do
    first_parser = Convoy.of(2)
    second_parser = Convoy.regexp(/lol/)
    first_parser_with_consumption = first_parser.consuming
    second_parser_with_consumption = second_parser.consuming

    first_result = first_parser_with_consumption.parse 'some text'
    second_result = second_parser_with_consumption.parse 'lol123'

    it 'can be transformer into a consuming parser with #consuming' do
      expect(first_result.succeed?).to be true
      expect(second_result.succeed?).to be true

      expect(first_result.completed?).to be true
      expect(second_result.remaining).to eq '123'
    end

    it 'can be transformed back with #non_consuming' do
      first_parser_back = first_parser_with_consumption.non_consuming
      second_parser_back = second_parser_with_consumption.non_consuming

      first_result_proper = first_parser.parse 'some text'
      second_result_proper = second_parser.parse 'lol123'

      first_result_back = first_parser_back.parse 'some text'
      second_result_back = second_parser_back.parse 'lol123'

      puts second_result

      expect(first_result_back).to eq first_result_proper
      expect(second_result_back).to eq second_result_proper
    end
  end
end
