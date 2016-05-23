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
    mock($stdout).write(
      "#{time.iso8601} [ INFO] #{$PROCESS_ID} : Hello World!\n"
    )

    logger.info 'Hello World!'
  end
end
