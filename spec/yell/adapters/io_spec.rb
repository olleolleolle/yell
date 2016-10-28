require 'spec_helper'

RSpec.describe Yell::Adapters::Io do
  it { is_expected.to be_kind_of(Yell::Adapters::Base) }

  context 'initialize' do
    it 'sets default :format' do
      adapter = Yell::Adapters::Io.new

      expect(adapter.format).to be_kind_of(Yell::Formatter)
    end

    context ':level' do
      let(:level) { Yell::Level.new(:warn) }

      it 'sets the level' do
        adapter = Yell::Adapters::Io.new(level: level)

        expect(adapter.level).to eq(level)
      end

      it 'sets the level when block was given' do
        adapter = Yell::Adapters::Io.new { |a| a.level = level }

        expect(adapter.level).to eq(level)
      end
    end

    context ':formatter' do
      let(:formatter) { Yell::Formatter.new }

      it 'sets the level' do
        adapter = Yell::Adapters::Io.new(formatter: formatter)

        expect(adapter.formatter).to eq(formatter)
      end

      it 'sets the level when block was given' do
        adapter = Yell::Adapters::Io.new { |a| a.formatter = formatter }

        expect(adapter.formatter).to eq(formatter)
      end
    end
  end

  context '#write' do
    let(:logger) { Yell::Logger.new }
    let(:event) { Yell::Event.new(logger, 1, 'Hello World') }
    let(:adapter) { Yell::Adapters::Io.new }
    let(:stream) { File.new('/dev/null', 'w') }

    before do
      allow(adapter).to receive(:stream) { stream }
    end

    it 'formats the message' do
      expect(adapter.format).to(
        receive(:call).with(event).and_call_original
      )

      adapter.write(event)
    end

    it 'prints formatted message to stream' do
      formatted = Yell::Formatter.new.call(event)
      expect(stream).to receive(:syswrite).with(formatted)

      adapter.write(event)
    end
  end
end
