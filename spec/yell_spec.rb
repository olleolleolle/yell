require 'spec_helper'

RSpec.describe Yell do
  let(:logger) { Yell.new }

  subject { logger }

  it { is_expected.to be_kind_of(Yell::Logger) }

  it 'raises AdapterNotFound when adapter cant be loaded' do
    expect { Yell.new(:unknownadapter) }.to raise_error(Yell::AdapterNotFound)
  end

  context '.level' do
    subject { Yell.level }
    it { is_expected.to be_kind_of(Yell::Level) }
  end

  context '.format' do
    subject { Yell.format('%m') }
    it { is_expected.to be_kind_of(Yell::Formatter) }
  end

  context '.load!' do
    subject { Yell.load!('yell.yml') }

    before do
      mock(Yell::Configuration).load!('yell.yml') { {} }
    end

    it { is_expected.to be_kind_of(Yell::Logger) }
  end

  context '.[]' do
    let(:name) { 'test' }

    it 'delegates to the repository' do
      mock(Yell::Repository)[name]

      Yell[name]
    end
  end

  context '.[]=' do
    let(:name) { 'test' }

    it 'delegates to the repository' do
      mock.proxy(Yell::Repository)[name] = logger

      Yell[name] = logger
    end
  end

  context '.env' do
    subject { Yell.env }

    context 'default' do
      it { is_expected.to eq('test') }
    end

    context 'fallback to RACK_ENV' do
      before do
        stub(ENV).key?('YELL_ENV') { false }
        mock(ENV).key?('RACK_ENV') { true }

        ENV['RACK_ENV'] = 'rack'
      end

      after { ENV.delete 'RACK_ENV' }

      it { is_expected.to eq('rack') }
    end

    context 'fallback to RAILS_ENV' do
      before do
        stub(ENV).key?('YELL_ENV') { false }
        stub(ENV).key?('RACK_ENV') { false }
        mock(ENV).key?('RAILS_ENV') { true }

        ENV['RAILS_ENV'] = 'rails'
      end

      after { ENV.delete 'RAILS_ENV' }

      it { is_expected.to eq('rails') }
    end

    context 'fallback to development' do
      before do
        stub(ENV).key?('YELL_ENV') { false }
        stub(ENV).key?('RACK_ENV') { false }
        stub(ENV).key?('RAILS_ENV') { false }
      end

      it { is_expected.to eq('development') }
    end
  end
end
