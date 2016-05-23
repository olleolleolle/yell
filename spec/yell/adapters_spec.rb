require 'spec_helper'

RSpec.describe Yell::Adapters do
  context '.new' do
    it 'accepts an adapter instance' do
      stdout = Yell::Adapters::Stdout.new
      adapter = Yell::Adapters.new(stdout)

      expect(adapter).to eq(stdout)
    end

    it 'accepts STDOUT' do
      mock.proxy(Yell::Adapters::Stdout).new(anything)

      Yell::Adapters.new(STDOUT)
    end

    it 'accepts STDERR' do
      mock.proxy(Yell::Adapters::Stderr).new(anything)

      Yell::Adapters.new(STDERR)
    end

    it 'raises an unregistered adapter' do
      expect do
        Yell::Adapters.new :unknown
      end.to raise_error(Yell::AdapterNotFound)
    end
  end

  context '.register' do
    let(:name) { :test }
    let(:klass) { mock }

    before { Yell::Adapters.register(name, klass) }

    it 'allows to being called from :new' do
      mock(klass).new(anything)

      Yell::Adapters.new(name)
    end
  end
end
