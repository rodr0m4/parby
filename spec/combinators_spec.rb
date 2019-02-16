require 'spec_helper'

describe Convoy, 'combinators' do
  context 'Convoy::of' do
    parser = Convoy.of(2)

    it 'Always succeeds' do
      first_result = parser.parse('something')
      second_result = parser.parse('another one')

      expect(first_result).to eq(second_result)
      expect(first_result).to eq(Success.new(0, 2))
    end
  end

  context 'Convoy::regexp' do
    parser = Convoy.regexp(/[0-9]0+/)

    it 'succeeds when matches some part of the string' do
      result = parser.parse('100stuff')

      expect(result.succeed?).to be true
      expect(result.completed?).to be false

      expect(result.value).to eq('100')
    end

    it 'succeds and completes when matches the whole string' do
      result = parser.parse('100')

      expect(result.succeded?).to be true
      expect(result.completed?).to be true

      expect(result.value).to eq('100')
    end

    it 'fails when does not match the regex from the start' do
      result = parser.parse('s100')

      expect(result.succeded?).to be false
      expect(result.completed?).to be false

      expect(result.expected).to eq([/[0-9]0+/])
    end
  end
end
