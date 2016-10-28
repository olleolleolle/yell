require 'spec_helper'

RSpec.describe Yell::Adapters do
  context '.new' do
    it 'accepts an adapter instance' do
      stdout = Yell::Adapters::Stdout.new
      adapter = Yell::Adapters.new(stdout)

      expect(adapter).to eq(stdout)
    end

    it 'accepts STDOUT' do
      expect(Yell::Adapters::Stdout).to receive(:new).with(anything)

      Yell::Adapters.new(STDOUT)
    end

    it 'accepts STDERR' do
      expect(Yell::Adapters::Stderr).to receive(:new).with(anything)

      Yell::Adapters.new(STDERR)
    end

    it 'raises an unregistered adapter' do
      expect do
        Yell::Adapters.new :unknown
      end.to raise_error(Yell::AdapterNotFound)
    end
  end

  context '.register' do
    let(:type) { :test }
    let(:klass) { double }

    before { Yell::Adapters.register(type, klass) }

    it 'allows to being called from :new' do
      expect(klass).to receive(:new)

      Yell::Adapters.new(type)
    end
  end
end
