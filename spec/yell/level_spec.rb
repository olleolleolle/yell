require 'spec_helper'

RSpec.describe Yell::Level do
  context 'default' do
    let(:level) { Yell::Level.new }

    it 'returns correctly' do
      expect(level.at?(:debug)).to eq(true)
      expect(level.at?(:info)).to eq(true)
      expect(level.at?(:warn)).to eq(true)
      expect(level.at?(:error)).to eq(true)
      expect(level.at?(:fatal)).to eq(true)
    end
  end

  context 'given a Symbol' do
    let(:level) { Yell::Level.new(severity) }

    context ':debug' do
      let(:severity) { :debug }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(true)
        expect(level.at?(:info)).to eq(true)
        expect(level.at?(:warn)).to eq(true)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(true)
      end
    end

    context ':info' do
      let(:severity) { :info }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(true)
        expect(level.at?(:warn)).to eq(true)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(true)
      end
    end

    context ':warn' do
      let(:severity) { :warn }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(false)
        expect(level.at?(:warn)).to eq(true)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(true)
      end
    end

    context ':error' do
      let(:severity) { :error }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(false)
        expect(level.at?(:warn)).to eq(false)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(true)
      end
    end

    context ':fatal' do
      let(:severity) { :fatal }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(false)
        expect(level.at?(:warn)).to eq(false)
        expect(level.at?(:error)).to eq(false)
        expect(level.at?(:fatal)).to eq(true)
      end
    end
  end

  context 'given a String' do
    let(:level) { Yell::Level.new(severity) }

    context 'basic string' do
      let(:severity) { 'error' }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(false)
        expect(level.at?(:warn)).to eq(false)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(true)
      end
    end

    context 'complex string with outer boundaries' do
      let(:severity) { 'gte.info lte.error' }

      it 'returns correctly' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(true)
        expect(level.at?(:warn)).to eq(true)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(false)
      end
    end

    context 'complex string with inner boundaries' do
      let(:severity) { 'gt.info lt.error' }

      it 'is valid' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(false)
        expect(level.at?(:warn)).to eq(true)
        expect(level.at?(:error)).to eq(false)
        expect(level.at?(:fatal)).to eq(false)
      end
    end

    context 'complex string with precise boundaries' do
      let(:severity) { 'at.info at.error' }

      it 'is valid' do
        expect(level.at?(:debug)).to eq(false)
        expect(level.at?(:info)).to eq(true)
        expect(level.at?(:warn)).to eq(false)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(false)
      end
    end

    context 'complex string with combined boundaries' do
      let(:severity) { 'gte.error at.debug' }

      it 'is valid' do
        expect(level.at?(:debug)).to eq(true)
        expect(level.at?(:info)).to eq(false)
        expect(level.at?(:warn)).to eq(false)
        expect(level.at?(:error)).to eq(true)
        expect(level.at?(:fatal)).to eq(true)
      end
    end
  end

  context 'given an Array' do
    let(:level) { Yell::Level.new([:debug, :warn, :fatal]) }

    it 'returns correctly' do
      expect(level.at?(:debug)).to eq(true)
      expect(level.at?(:info)).to eq(false)
      expect(level.at?(:warn)).to eq(true)
      expect(level.at?(:error)).to eq(false)
      expect(level.at?(:fatal)).to eq(true)
    end
  end

  context 'given a Range' do
    let(:level) { Yell::Level.new((1..3)) }

    it 'returns correctly' do
      expect(level.at?(:debug)).to eq(false)
      expect(level.at?(:info)).to eq(true)
      expect(level.at?(:warn)).to eq(true)
      expect(level.at?(:error)).to eq(true)
      expect(level.at?(:fatal)).to eq(false)
    end
  end

  context 'given a Yell::Level instance' do
    let(:level) { Yell::Level.new(:warn) }

    it 'returns correctly' do
      expect(level.at?(:debug)).to eq(false)
      expect(level.at?(:info)).to eq(false)
      expect(level.at?(:warn)).to eq(true)
      expect(level.at?(:error)).to eq(true)
      expect(level.at?(:fatal)).to eq(true)
    end
  end

  context 'backwards compatibility' do
    let(:level) { Yell::Level.new :warn }

    it 'returns correctly to :to_i' do
      expect(level.to_i).to eq(2)
    end

    it 'typecasts with Integer correctly' do
      expect(Integer(level)).to eq(2)
    end

    it 'is compatible when passing to array' do
      severities = %w(FINE INFO WARNING SEVERE SEVERE INFO)

      expect(severities[level]).to eq('WARNING')
    end
  end
end
