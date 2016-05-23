require 'spec_helper'

RSpec.describe Yell::Repository do
  let(:name) { 'test' }
  let(:logger) { Yell.new(:stdout) }

  subject { Yell::Repository[name] }

  context '.[]' do
    it 'raises when not set' do
      expect { subject }.to raise_error(Yell::LoggerNotFound)
    end

    context 'when logger with :name exists' do
      let!(:logger) { Yell.new(:stdout, name: name) }

      it { is_expected.to eq(logger) }
    end

    context 'given a Class' do
      let!(:logger) { Yell.new(:stdout, name: 'Numeric') }

      it 'raises with the correct :name when logger not found' do
        expect { Yell::Repository[String] }.to raise_error(Yell::LoggerNotFound)
      end

      it 'returns the logger' do
        expect(Yell::Repository[Numeric]).to eq(logger)
      end

      it 'returns the logger when superclass has it defined' do
        expect(Yell::Repository[Integer]).to eq(logger)
      end
    end
  end

  context '.[]=' do
    before { Yell::Repository[name] = logger }

    it { is_expected.to eq(logger) }
  end

  context '.[]= with a named logger' do
    let!(:logger) { Yell.new(:stdout, name: name) }
    before { Yell::Repository[name] = logger }

    it { is_expected.to eq(logger) }
  end

  context '.[]= with a named logger of a different name' do
    let(:other) { 'other' }
    let(:logger) { Yell.new(:stdout, name: other) }
    before { Yell::Repository[name] = logger }

    it 'adds logger to both repositories' do
      expect(Yell::Repository[name]).to eq(logger)
      expect(Yell::Repository[other]).to eq(logger)
    end
  end

  context 'loggers' do
    let(:loggers) { { name => logger } }
    subject { Yell::Repository.loggers }
    before { Yell::Repository[name] = logger }

    it { is_expected.to eq(loggers) }
  end
end
