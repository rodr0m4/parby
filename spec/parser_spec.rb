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
