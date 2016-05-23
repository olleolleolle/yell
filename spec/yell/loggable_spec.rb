require 'spec_helper'

class LoggableFactory #:nodoc:
  include Yell::Loggable
end

RSpec.describe Yell::Loggable do
  let(:factory) { LoggableFactory.new }
  subject { factory }

  it { is_expected.to respond_to(:logger) }

  it 'performs a lookup in the Yell::Repository' do
    mock(Yell::Repository)[LoggableFactory]

    factory.logger
  end
end
