require 'spec_helper'

RSpec.describe Yell::Event do
  let(:logger) { Yell::Logger.new(trace: true) }
  let(:event) { Yell::Event.new(logger, 1, 'Hello World!') }

  context '#level' do
    subject { event.level }
    it { is_expected.to eq(1) }
  end

  context '#messages' do
    subject { event.messages }
    it { is_expected.to eq(['Hello World!']) }
  end

  context '#time' do
    let(:time) { Time.now }
    subject { event.time.to_s }

    before { Timecop.freeze(time) }

    it { is_expected.to eq(time.to_s) }
  end

  context '#hostname' do
    subject { event.hostname }
    it { is_expected.to eq(Socket.gethostname) }
  end

  context '#pid' do
    subject { event.pid }
    it { is_expected.to eq($PROCESS_ID) } # explicitly NOT using $PROCESS_ID
  end

  context '#id when forked', pending: RUBY_PLATFORM == 'java' do
    subject { @pid }

    before do
      read, write = IO.pipe

      @pid = Process.fork do
        event = Yell::Event.new(logger, 1, 'Hello World!')
        write.puts event.pid
      end
      Process.wait
      write.close

      @child_pid = read.read.to_i
      read.close
    end

    it { is_expected.to_not eq(Process.pid) }
    it { is_expected.to eq(@child_pid) }
  end

  context '#progname' do
    subject { event.progname }
    it { is_expected.to eq($PROGRAM_NAME) } # explicitly NOT using $PROGRAM_NAME
  end
end
