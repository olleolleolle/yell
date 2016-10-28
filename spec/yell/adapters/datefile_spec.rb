require 'spec_helper'

RSpec.describe Yell::Adapters::Datefile do
  let(:logger) { Yell::Logger.new }
  let(:message) { 'Hello World' }
  let(:event) { Yell::Event.new(logger, 1, message) }

  let(:today) { Time.now }
  let(:tomorrow) { Time.now + 86_400 }
  let(:date_pattern) { Yell::Adapters::Datefile::DefaultDatePattern }

  let(:filename) { fixture_path.join('test.log') }
  let(:today_filename) do
    fixture_path.join("test.#{today.strftime(date_pattern)}.log")
  end
  let(:tomorrow_filename) do
    fixture_path.join("test.#{tomorrow.strftime(date_pattern)}.log")
  end

  let(:adapter) do
    Yell::Adapters::Datefile.new(filename: filename, format: '%m')
  end

  before do
    Timecop.freeze(today)
  end

  it { is_expected.to be_kind_of Yell::Adapters::File }

  describe '#write' do
    let(:today_lines) { File.readlines(today_filename) }

    before do
      adapter.write(event)
    end

    it 'outputs to filename with date pattern' do
      expect(File.exist?(today_filename)).to eq(true)

      expect(today_lines.size).to eq(2) # includes header line
      expect(today_lines.last).to match(message)
    end

    it 'outputs to the same file' do
      adapter.write(event)

      expect(File.exist?(today_filename)).to eq(true)
      expect(today_lines.size).to eq(3) # includes header line
    end

    it 'does not open file handle again' do
      expect(File).to_not receive(:open).with(anything, anything)

      adapter.write(event)
    end

    context 'on rollover' do
      let(:tomorrow_lines) { File.readlines(tomorrow_filename) }

      before do
        Timecop.freeze(tomorrow) { adapter.write(event) }
      end

      it 'rotates file' do
        expect(File.exist?(tomorrow_filename)).to eq(true)

        expect(tomorrow_lines.size).to eq(2) # includes header line
        expect(tomorrow_lines.last).to match(message)
      end
    end
  end

  describe '#keep' do
    before do
      adapter.symlink = false # to not taint the Dir
      adapter.keep = 2

      adapter.write(event)
    end

    it 'keeps the specified number or files upon rollover' do
      expect(Dir[fixture_path.join('*.log')].size).to eq(1)

      Timecop.freeze(tomorrow) { adapter.write(event) }
      expect(Dir[fixture_path.join('*.log')].size).to eq(2)

      Timecop.freeze(tomorrow + 86_400) { adapter.write(event) }
      expect(Dir[fixture_path.join('*.log')].size).to eq(2)
    end
  end

  describe '#symlink' do
    context 'when true (default)' do
      before do
        adapter.write(event)
      end

      it 'is created on the original filename' do
        expect(File.symlink?(filename)).to eq(true)
        expect(File.readlink(filename)).to eq(today_filename.to_s)
      end

      it 'is recreated upon rollover' do
        Timecop.freeze(tomorrow) { adapter.write(event) }

        expect(File.symlink?(filename)).to eq(true)
        expect(File.readlink(filename)).to eq(tomorrow_filename.to_s)
      end
    end

    context 'when false' do
      before do
        adapter.symlink = false
      end

      it 'does not create the sylink the original filename' do
        adapter.write(event)

        expect(File.symlink?(filename)).to eq(false)
      end
    end
  end

  describe '#header' do
    let(:header) { File.open(today_filename, &:readline) }

    context 'when true (default)' do
      before do
        adapter.write(event)
      end

      it 'is written' do
        expect(header).to match(Yell::Adapters::Datefile::HeaderRegexp)
      end

      it 'is rewritten upon rollover' do
        Timecop.freeze(tomorrow) { adapter.write(event) }

        expect(File.symlink?(filename)).to eq(true)
        expect(File.readlink(filename)).to eq(tomorrow_filename.to_s)
      end
    end

    context 'when false' do
      before do
        adapter.header = false
      end

      it 'is not written' do
        adapter.write(event)

        expect(header).to eq("Hello World\n")
      end
    end
  end

  context 'another adapter with the same :filename' do
    let(:another_adapter) { Yell::Adapters::Datefile.new(filename: filename) }

    before do
      adapter.write(event)
    end

    it 'does not write the header again' do
      another_adapter.write(event)

      # 1: header
      # 2: adapter write
      # 3: another_adapter: write
      expect(File.readlines(today_filename).size).to eq(3)
    end
  end
end
