require 'spec_helper'

RSpec.describe Yell::Logger do
  let(:filename) { fixture_path.join('logger.log') }

  describe 'a Logger instance' do
    let(:logger) { Yell::Logger.new }
    subject { logger }

    context 'log methods' do
      it { is_expected.to respond_to(:debug) }
      it { is_expected.to respond_to(:debug?) }

      it { is_expected.to respond_to(:info) }
      it { is_expected.to respond_to(:info?) }

      it { is_expected.to respond_to(:warn) }
      it { is_expected.to respond_to(:warn?) }

      it { is_expected.to respond_to(:error) }
      it { is_expected.to respond_to(:error?) }

      it { is_expected.to respond_to(:fatal) }
      it { is_expected.to respond_to(:fatal?) }

      it { is_expected.to respond_to(:unknown) }
      it { is_expected.to respond_to(:unknown?) }
    end

    context 'default #name' do
      it 'returns the correct name' do
        expect(logger.name).to eq("<Yell::Logger##{logger.object_id}>")
      end

      it 'does not add to the repository' do
        expect { Yell::Repository[logger.name] }.to(
          raise_error(Yell::LoggerNotFound)
        )
      end
    end

    context 'default #adapter' do
      subject { logger.adapters.instance_variable_get(:@collection) }

      it { is_expected.to be_kind_of(Yell::Adapters::File) }
    end

    context 'default #level' do
      subject { logger.level }

      it { is_expected.to be_instance_of(Yell::Level) }

      it 'returns the correct severities' do
        expect(subject.severities).to eq([true, true, true, true, true, true])
      end
    end
  end

  describe 'initialize with #name' do
    let(:name) { 'test' }
    let!(:logger) { Yell.new(name: name) }

    it 'sets the name correctly' do
      expect(logger.name).to eq(name)
    end

    it 'adds to the repository' do
      expect(Yell::Repository[name]).to eq(logger)
    end
  end

  context 'initialize with #level' do
    let(:level) { :error }
    let(:logger) { Yell.new(level: level) }
    subject { logger.level }

    it { is_expected.to be_instance_of(Yell::Level) }

    it 'returns the correct severities' do
      expect(subject.severities).to eq([false, false, false, true, true, true])
    end
  end

  context 'initialize with #silence' do
    let(:silence) { 'test' }
    let(:logger) { Yell.new(silence: silence) }
    subject { logger.silencer }

    it { is_expected.to be_instance_of(Yell::Silencer) }

    it 'returns the correct patterns' do
      expect(subject.patterns).to eq([silence])
    end
  end

  context 'initialize with a #filename' do
    it 'should call adapter with :file' do
      expect(Yell::Adapters::File).to(
        receive(:new).with(filename: filename).and_call_original
      )

      Yell::Logger.new(filename)
    end
  end

  context 'initialize with a #filename of Pathname type' do
    let(:pathname) { Pathname.new(filename) }

    it 'calls adapter with :file' do
      expect(Yell::Adapters::File).to(
        receive(:new).with(filename: pathname).and_call_original
      )

      Yell::Logger.new(pathname)
    end
  end

  context 'initialize with a :stdout adapter' do
    before do
      expect(Yell::Adapters::Stdout).to receive(:new)
    end

    it 'calls adapter with STDOUT' do
      Yell::Logger.new(STDOUT)
    end

    it 'calls adapter with :stdout' do
      Yell::Logger.new(:stdout)
    end
  end

  context 'initialize with a :stderr adapter' do
    before do
      expect(Yell::Adapters::Stderr).to receive(:new)
    end

    it 'calls adapter with STDERR' do
      Yell::Logger.new(STDERR)
    end

    it 'calls adapter with :stderr' do
      Yell::Logger.new(:stderr)
    end
  end

  context 'initialize with a block' do
    let(:level) { Yell::Level.new :error }
    let(:adapters) { logger.adapters.instance_variable_get(:@collection) }

    context 'with arity' do
      let(:logger) do
        Yell::Logger.new(level: level) { |l| l.adapter(:stdout) }
      end

      it 'passes the level correctly' do
        expect(logger.level).to eq(level)
      end

      it 'passes the adapter correctly' do
        expect(adapters).to be_instance_of(Yell::Adapters::Stdout)
      end
    end
  end

  context 'initialize with #adapters option' do
    it 'sets adapters in logger correctly' do
      expect(Yell::Adapters::Stdout).to receive(:new)
      expect(Yell::Adapters::Stderr).to(
        receive(:new).with(hash_including(level: :error))
      )

      Yell::Logger.new(adapters: [:stdout, { stderr: { level: :error } }])
    end
  end

  context 'logging in general' do
    let(:logger) { Yell::Logger.new(filename, format: '%m') }
    let(:line) { File.open(filename, &:readline) }

    it 'outputs a single message' do
      logger.info 'Hello World'

      expect(line).to eq("Hello World\n")
    end

    it 'outputs multiple messages' do
      logger.info %w(Hello W o r l d)

      expect(line).to eq("Hello W o r l d\n")
    end

    it 'outputs a hash and message' do
      logger.info ['Hello World', { test: :message }]

      expect(line).to eq("Hello World test: message\n")
    end

    it 'outputs a hash and message' do
      logger.info [{ test: :message }, 'Hello World']

      expect(line).to eq("test: message Hello World\n")
    end

    it 'outputs a hash and block' do
      logger.info(test: :message) { 'Hello World' }

      expect(line).to eq("test: message Hello World\n")
    end
  end

  context 'logging with a silencer' do
    let(:silence) { 'this' }
    let(:stdout) { Yell::Adapters::Stdout.new }
    let(:logger) { Yell::Logger.new(stdout, silence: silence) }

    it 'does not pass a matching message to any adapter' do
      expect(stdout).to_not receive(:write)

      logger.info 'this is not logged'
    end

    it 'passes a non-matching message to any adapter' do
      expect(stdout).to receive(:write).with(kind_of(Yell::Event))

      logger.info 'that is logged'
    end
  end
end
