require 'spec_helper.rb'

describe Result do
  context 'did fail' do
    result = Failure.new(10, ['stuff'])

    it 'when the status is false' do
      expect(result.failed?).to be true
      expect(result.succeed?).to be false
    end
  end

  context 'did succeed' do
    result = Success.new(1, nil)

    it 'when the status is true' do
      expect(result.failed?).to be false
      expect(result.succeed?).to be true
    end
  end

  context 'did complete' do
    success = Success.new(nil, nil, 'x')
    failure = Success.new(nil, [], 'x')

    it 'when there is still input to be consumed, and does not matter if it succeeded or not' do
      expect(success.completed?).to be false
      expect(failure.completed?).to be false
    end
  end
end
