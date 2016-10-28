require 'spec_helper'

RSpec.describe Yell::Adapters::File do
  let(:devnull) { File.new('/dev/null', 'w') }

  before do
    allow(File).to receive(:open) { devnull }
  end

  it { is_expected.to be_kind_of(Yell::Adapters::Io) }

  context '#stream' do
    subject { Yell::Adapters::File.new.send(:stream) }

    it { is_expected.to be_kind_of(File) }
  end

  context '#write' do
    let(:logger) { Yell::Logger.new }
    let(:event) { Yell::Event.new(logger, 1, 'Hello World') }

    context 'default filename' do
      let(:filename) { File.expand_path "#{Yell.env}.log" }
      let(:adapter) { Yell::Adapters::File.new }

      it 'prints to file' do
        mod = File::WRONLY | File::APPEND | File::CREAT
        expect(File).to(
          receive(:open)
            .with(filename, mod) { devnull }
        )

        adapter.write(event)
      end
    end

    context 'with given :filename' do
      let(:filename) { fixture_path.join('filename.log').to_s }
      let(:adapter) { Yell::Adapters::File.new(filename: filename) }

      it 'prints to file' do
        mod = File::WRONLY | File::APPEND | File::CREAT
        expect(File).to(
          receive(:open)
            .with(filename, mod) { devnull }
        )

        adapter.write(event)
      end
    end

    context 'with given :pathname' do
      let(:pathname) { Pathname.new(fixture_path).join('filename.log') }
      let(:adapter) { Yell::Adapters::File.new(filename: pathname) }

      it 'accepts pathanme as filename' do
        mod = File::WRONLY | File::APPEND | File::CREAT
        expect(File).to(
          receive(:open)
            .with(pathname.to_s, mod) { devnull }
        )

        adapter.write(event)
      end
    end

    context '#sync' do
      let(:adapter) { Yell::Adapters::File.new }

      it 'syncs by default' do
        expect(devnull).to receive(:sync=).with(true)

        adapter.write(event)
      end

      it 'passes the option to File' do
        adapter.sync = false
        expect(devnull).to receive(:sync=).with(false)

        adapter.write(event)
      end
    end
  end
end
