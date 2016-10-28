require 'spec_helper'

RSpec.describe 'Yell Adapter DSL spec' do
  class DSLAdapter < Yell::Adapters::Base #:nodoc:
    attr_reader :test_setup,
                :test_write,
                :test_close

    setup do |_options|
      @test_setup = true
    end

    write do |_event|
      @test_write = true
    end

    close do
      @test_close = true
    end
  end

  it 'performs #setup' do
    adapter = DSLAdapter.new
    expect(adapter.test_setup).to eq(true)
  end

  it 'performs #write' do
    event = double(level: 0)

    adapter = DSLAdapter.new
    expect(adapter.test_write).to be_nil

    adapter.write(event)
    expect(adapter.test_write).to eq(true)
  end

  it 'performs #close' do
    adapter = DSLAdapter.new
    expect(adapter.test_close).to be_nil

    adapter.close
    expect(adapter.test_close).to eq(true)
  end
end
