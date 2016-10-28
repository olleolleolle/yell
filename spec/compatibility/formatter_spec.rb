require 'spec_helper'
require 'logger'

RSpec.describe 'backwards compatible formatter' do
  let(:time) { Time.now }
  let(:formatter) { Yell::Formatter.new(Yell::DefaultFormat) }
  let(:logger) { Logger.new($stdout) }

  before do
    Timecop.freeze(time)
    logger.formatter = formatter
  end

  it 'formats out the message correctly' do
    message = "#{time.iso8601} [ INFO] #{$PROCESS_ID} : Hello World!\n"
    expect($stdout).to receive(:write).with(message)

    logger.info 'Hello World!'
  end
end
