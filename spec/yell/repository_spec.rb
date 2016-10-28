require 'spec_helper'

RSpec.describe Yell::Repository do
  context '.[]' do
    it 'raises when not set' do
      expect do
        Yell::Repository['undefined']
      end.to raise_error(Yell::LoggerNotFound)
    end

    context 'when an instance with :name exists' do
      let!(:logger) { Yell.new(:stdout, name: 'foo') }

      it 'returns the logger' do
        expect(Yell::Repository['foo']).to eq(logger)
      end
    end
  end

  context '.[] when passing a Class' do
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

  context '.[]=' do
    let!(:logger) { Yell.new(:stdout, name: 'Numeric') }
    before { Yell::Repository['foo'] = logger }

    it 'sets the logger' do
      expect(Yell::Repository['foo']).to eq(logger)
    end
  end

  context '.[]= with a named instance' do
    let!(:logger) { Yell.new(:stdout, name: 'foo') }
    before { Yell::Repository['bar'] = logger }

    it 'adds logger to both repositories' do
      expect(Yell::Repository['foo']).to eq(logger)
      expect(Yell::Repository['bar']).to eq(logger)
    end
  end

  context 'loggers' do
    let!(:logger) { Yell.new(:stdout, name: 'foo') }
    before { Yell::Repository['foo'] = logger }

    it 'should eq(loggers)' do
      expect(Yell::Repository.loggers).to eq('foo' => logger)
    end
  end
end
