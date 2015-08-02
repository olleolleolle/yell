require 'spec_helper'

RSpec.describe 'Yell Adapter DSL spec' do
  class DSLAdapter < Yell::Adapters::Base #:nodoc:
    setup do |_options|
      @test_setup = true
    end

    write do |_event|
      @test_write = true
    end

    close do
      @test_close = true
    end

    def test_setup?
      @test_setup == true
    end

    def test_write?
      @test_write == true
    end

    def test_close?
      @test_close == true
    end
  end

  it 'should perform #setup' do
    adapter = DSLAdapter.new
    expect(adapter.test_setup?).to eq(true)
  end

  it 'should perform #write' do
    event = 'event'
    stub(event).level { 0 }

    adapter = DSLAdapter.new
    expect(adapter.test_write?).to eq(false)

    adapter.write(event)
    expect(adapter.test_write?).to eq(true)
  end

  it 'should perform #close' do
    adapter = DSLAdapter.new
    expect(adapter.test_close?).to eq(false)

    adapter.close
    expect(adapter.test_close?).to eq(true)
  end
end
