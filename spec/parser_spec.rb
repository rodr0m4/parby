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
  context('Given two parsers') do
    parser = Convoy.regexp(/42/) | Convoy.of(42)

    it('When the first one succeeds it yields, not calling the second one') do
      result = parser.parse('42')

      expect(result.succeded?).to be true
      expect(result.value).to eq('42')
    end

    it('When the first one succeeds it calls the second one') do
      result = parser.parse('lol')

      expect(result.succeded?).to be true
      expect(result.value).to eq(42)
    end
  end
end

describe Parser, '#>>' do
  context('Given two parsers') do
    first_parser = Convoy.regexp(/0/)
    second_parser = spy(Convoy.regexp(/[0-9]+/))

    parser = first_parser >> second_parser

    it('Both should have to match to succeed, but only the second value is yielded') do
      result = parser.parse('00')

      expect(result.succeded?).to be true
      expect(result.value).to eq('00')
    end

    it('When the first one fails, the other one is not called') do
      result = parser.parse('lol')

      expect(result.failed?).to be true
      expect(second_parser).to_not have_received(:parse)
    end
  end
end
