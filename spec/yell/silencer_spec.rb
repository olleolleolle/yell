require 'spec_helper'

RSpec.describe Yell::Silencer do
  context 'initialize with #patterns' do
    subject { Yell::Silencer.new(/this/) }

    it 'returns the right patterns' do
      expect(subject.patterns).to eq([/this/])
    end
  end

  context '#add' do
    let(:silencer) { Yell::Silencer.new }

    it 'adds patterns' do
      silencer.add(/this/, /that/)
      expect(silencer.patterns).to eq([/this/, /that/])
    end

    it 'ignores duplicate patterns' do
      silencer.add(/this/, /that/, /this/)
      expect(silencer.patterns).to eq([/this/, /that/])
    end
  end

  context '#call' do
    let(:silencer) { Yell::Silencer.new(/this/) }

    it 'rejects messages that match any pattern' do
      expect(silencer.call('this')).to eq([])
      expect(silencer.call('that')).to eq(['that'])
      expect(silencer.call('this', 'that')).to eq(['that'])
    end
  end
end
