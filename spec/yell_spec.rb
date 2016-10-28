require 'spec_helper'

RSpec.describe Yell do
  let(:logger) { Yell.new }

  it 'should be_kind_of Yell::Logger' do
    expect(logger).to be_a_kind_of(Yell::Logger)
  end

  it 'raises AdapterNotFound when adapter cant be loaded' do
    expect { Yell.new(:unknownadapter) }.to raise_error(Yell::AdapterNotFound)
  end

  context '.level' do
    let(:level) { Yell.level }

    it 'should be_kind_of Yell::Level' do
      expect(level).to be_a_kind_of(Yell::Level)
    end
  end

  context '.format' do
    let(:format) { Yell.format('%m') }

    it 'should be_kind_of Yell::Formatter' do
      expect(format).to be_a_kind_of(Yell::Formatter)
    end
  end

  context '.load!' do
    let(:logger) { Yell.load!('yell.yml') }

    before do
      expect(Yell::Configuration).to(
        receive(:load!).with('yell.yml') { {} }
      )
    end

    it 'should be_kind_of Yell::Logger' do
      expect(logger).to be_a_kind_of(Yell::Logger)
    end
  end

  context '.[]' do
    let(:name) { 'test' }

    it 'should delegate to the repository' do
      expect(Yell::Repository).to receive(:[]).with(name)

      Yell[name]
    end
  end

  context '.[]=' do
    let(:name) { 'test' }

    it 'should delegate to the repository' do
      expect(Yell::Repository).to(
        receive(:[]=).with(name, logger).and_call_original
      )

      Yell[name] = logger
    end
  end

  context '.env' do
    let(:env) { Yell.env }

    it 'defaults to YELL_ENV' do
      expect(env).to eq('test')
    end

    context 'fallback to RACK_ENV' do
      before do
        expect(ENV).to receive(:key?).with('YELL_ENV') { false }
        expect(ENV).to receive(:key?).with('RACK_ENV') { true }

        ENV['RACK_ENV'] = 'rack'
      end

      after { ENV.delete 'RACK_ENV' }

      it 'returns correctly' do
        expect(env).to eq('rack')
      end
    end

    context 'fallback to RAILS_ENV' do
      before do
        expect(ENV).to receive(:key?).with('YELL_ENV') { false }
        expect(ENV).to receive(:key?).with('RACK_ENV') { false }
        expect(ENV).to receive(:key?).with('RAILS_ENV') { true }

        ENV['RAILS_ENV'] = 'rails'
      end

      after { ENV.delete 'RAILS_ENV' }

      it 'returns correctly' do
        expect(env).to eq('rails')
      end
    end

    context 'fallback to development' do
      before do
        expect(ENV).to receive(:key?).with('YELL_ENV') { false }
        expect(ENV).to receive(:key?).with('RACK_ENV') { false }
        expect(ENV).to receive(:key?).with('RAILS_ENV') { false }
      end

      it 'returns correctly' do
        expect(env).to eq('development')
      end
    end
  end
end
