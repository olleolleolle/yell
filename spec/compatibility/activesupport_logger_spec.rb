# encoding: utf-8
require 'spec_helper'
require 'active_support'

# make a setup just like in railties ~> 4.0.0
#
# We simulate the case when Rails 4 starts up its server
# and wants to append the log output.

def has_active_support?
  defined?(ActiveSupport) && ActiveSupport::VERSION::MAJOR >= 4
end

RSpec.describe 'Compatibility to ActiveSupport::Logger',
               pending: !has_active_support? do

  let!(:yell) { Yell.new($stdout, format: '%m') }

  let!(:logger) do
    console = ActiveSupport::Logger.new($stdout)
    console.formatter = yell.formatter
    console.level = yell.level

    yell.extend(ActiveSupport::Logger.broadcast(console))

    console
  end

  it 'behaves correctly' do
    expect($stdout).to receive(:syswrite).with("Hello World\n") # yell
    expect($stdout).to receive(:write).with("Hello World\n") # logger

    yell.info 'Hello World'
  end
end
