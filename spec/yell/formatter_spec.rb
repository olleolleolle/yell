require 'spec_helper'

RSpec.describe Yell::Formatter do
  let(:logger) { Yell::Logger.new(:stdout, name: 'Yell') }
  let(:message) { 'Hello World!' }
  let(:event) { Yell::Event.new(logger, 1, message) }
  let(:time) { Time.now }

  let(:pattern) { '%m' }
  let(:formatter) { Yell::Formatter.new(pattern) }

  subject { formatter.call(event) }

  before do
    Timecop.freeze(time)
  end

  describe 'patterns' do
    context '%m' do
      let(:pattern) { '%m' }
      it { is_expected.to eq("#{event.messages.join(' ')}\n") }
    end

    context '%l' do
      let(:pattern) { '%l' }
      it { is_expected.to eq("#{Yell::Severities[event.level][0, 1]}\n") }
    end

    context '%L' do
      let(:pattern) { '%L' }
      it { is_expected.to eq("#{Yell::Severities[event.level]}\n") }
    end

    context '%d' do
      let(:pattern) { '%d' }
      it { is_expected.to eq("#{event.time.iso8601}\n") }
    end

    context '%p' do
      let(:pattern) { '%p' }
      it { is_expected.to eq("#{event.pid}\n") }
    end

    context '%P' do
      let(:pattern) { '%P' }
      it { is_expected.to eq("#{event.progname}\n") }
    end

    context '%t' do
      let(:pattern) { '%t' }
      it { is_expected.to eq("#{event.thread_id}\n") }
    end

    context '%h' do
      let(:pattern) { '%h' }
      it { is_expected.to eq("#{event.hostname}\n") }
    end
  end

  describe 'presets' do
    context 'NoFormat' do
      let(:pattern) { Yell::NoFormat }
      it { is_expected.to eq("Hello World!\n") }
    end

    context 'DefaultFormat' do
      let(:pattern) { Yell::DefaultFormat }
      let(:output) do
        [
          time.iso8601,
          '[ INFO]',
          $PROCESS_ID,
          ": #{message}"
        ].join(' ')
      end

      it { is_expected.to eq(output + "\n") }
    end

    context 'BasicFormat' do
      let(:pattern) { Yell::BasicFormat }
      it { is_expected.to eq("I, #{time.iso8601} : Hello World!\n") }
    end

    context 'ExtendedFormat' do
      let(:pattern) { Yell::ExtendedFormat }
      let(:output) do
        [
          time.iso8601,
          '[ INFO]',
          $PROCESS_ID,
          Socket.gethostname,
          ": #{message}"
        ].join(' ')
      end

      it { is_expected.to eq(output + "\n") }
    end
  end

  describe 'custom formats' do
    context 'leading unknown formats' do
      let(:pattern) { '%x %m' }
      it { is_expected.to eq("%x Hello World!\n") }
    end

    context 'tailing unknown formats' do
      let(:pattern) { '%m %x' }
      it { is_expected.to eq("Hello World! %x\n") }
    end

    context 'consecutive %' do
      let(:pattern) { '%%%% %m %%%%' }
      it { is_expected.to eq("%%%% Hello World! %%%%\n") }
    end
  end

  describe 'Exception' do
    let(:message) { StandardError.new('Exceptional') }

    before do
      allow(message).to receive(:backtrace) { ['backtrace'] }
    end

    it { is_expected.to eq("StandardError: Exceptional\n\tbacktrace\n") }
  end

  describe 'Hash' do
    let(:message) { { test: 'message' } }

    it { is_expected.to eq("test: message\n") }
  end

  describe 'custom message modifiers' do
    let(:formatter) do
      Yell::Formatter.new(pattern) do |f|
        f.modify(String) { |m| "Modified! #{m}" }
      end
    end

    it { is_expected.to eq("Modified! #{message}\n") }
  end
end
