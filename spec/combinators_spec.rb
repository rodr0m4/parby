require 'spec_helper'

describe Convoy, '#of' do
  describe '#of' do
    parser = Convoy.of(2)

    it 'Always succeeds' do
      first_result = parser.parse('something')
      second_result = parser.parse('another one')

      expect(first_result.value).to eq(second_result.value)
      expect(first_result).to eq(Success.new(0, 2, 'something'))
    end
  end

  describe '#regexp' do
    parser = Convoy.regexp(/[0-9]0+/)

    it 'searches for a match in the input string, yields it' do
      result = parser.parse('100j')

      expect(result.succeed?).to be true
      expect(result.completed?).to be false
      expect(result.remaining).to eq('100j')

      expect(result.value).to eq('100')
    end

    it 'fails when it does not match a regex from the start' do
      result = parser.parse('j100')

      expect(result.succeed?).to be false
      expect(result.completed?).to be false

      expect(result.expected).to eq([/[0-9]0+/])
    end
  end

  describe '#one_of' do
    parser = Convoy.one_of('123')

    it 'looks for exactly one character from the given string, and yields that character' do
      result = parser.parse('jmvbn2')

      expect(result.succeed?).to be true
      expect(result.remaining).to eq('jmvbn2')

      expect(result.value).to eq('2')
    end

    it 'it short circuits' do
      result = parser.parse('123')

      expect(result.succeed?).to be true
      expect(result.remaining).to eq('123')

      expect(result.value).to eq('1')
    end
  end

  describe '#string' do
    parser = Convoy.string('Hi!')

    it 'matches whole string and consumes it' do
      result = parser.parse 'Hi!'

      expect(result.succeed?).to be true
      expect(result.value).to eq 'Hi!'
    end

    it 'Fails gracefully: says the piece of the string that it matched' do
      result = parser.parse 'Hi'

      expect(result.failed?).to be true
      expect(result.expected).to eq ['Hi!']
      expect(result.furthest).to eq 1
    end
  end

  describe '#all' do
    it 'consumes the whole input, and yields it' do
      result = Convoy.all.parse 42

      expect(result.succeed?).to be true
      expect(result.completed?).to be true
      expect(result.value).to eq 42
    end
  end
end