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

  describe '#test' do
    context 'given a predicate' do
      parser = Convoy.test(Proc.new { |c| c.between?('a', 'z') }, 'Alphanumeric character') # This is how Convoy#between is implemented

      context 'applies the predicate to each character in input' do
        context 'if it matches in the first character' do
          matches_first = parser.parse 'airplane'

          it 'yields and does not consume the input' do
            expect(matches_first.succeed?).to be true
            expect(matches_first.completed?).to be false
            expect(matches_first.value).to eq 'a'
            expect(matches_first.remaining).to eq 'airplane'
          end
        end

        context 'if it matches in the middle of the string' do
          matches_in_the_middle = parser.parse '_eval'

          it 'yields and does not consume the input' do
            expect(matches_in_the_middle.succeed?).to be true
            expect(matches_in_the_middle.completed?).to be false
            expect(matches_in_the_middle.value).to eq 'e'
            expect(matches_in_the_middle.remaining).to eq '_eval'
          end
        end

        context 'if it does not match' do
          does_not_match = parser. parse '>>='

          it 'fails with the given message and does not consume the input' do
            expect(does_not_match.failed?).to be true
            expect(does_not_match.expected).to eq ['Alphanumeric character']
            expect(does_not_match.remaining).to eq '>>='
          end
        end
      end
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

    it 'short circuits' do
      result = parser.parse('123')

      expect(result.succeed?).to be true
      expect(result.remaining).to eq('123')

      expect(result.value).to eq('1')
    end
  end

  describe '#none_of' do
    parser = Convoy.none_of '123'

    it 'succeeds when it founds a character not in the string, and yields it' do
      result = parser.parse '1kl'

      expect(result.succeed?).to be true
      expect(result.value).to eq 'k'
      expect(result.remaining).to eq '1kl'
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
