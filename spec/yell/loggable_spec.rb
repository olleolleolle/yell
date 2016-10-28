require 'spec_helper'

class LoggableFactory #:nodoc:
  include Yell::Loggable
end

RSpec.describe Yell::Loggable do
  subject { LoggableFactory.new }

  it { is_expected.to respond_to(:logger) }

  it 'performs a lookup in the Yell::Repository' do
    expect(Yell::Repository).to(
      receive(:[]).with(LoggableFactory)
    )

    subject.logger
  end
end
