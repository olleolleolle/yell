$LOAD_PATH.unshift File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['YELL_ENV'] = 'test'
require 'yell'

require 'rspec/core'
require 'rspec/expectations'
require 'rr'
require 'timecop'

begin
  require 'pry'
rescue LoadError
  # do nothing
end

begin
  require 'coveralls'
  require 'simplecov'

  STDERR.puts 'Running coverage...'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    add_filter 'spec'
  end
rescue LoadError
  # do nothing
end

RSpec.configure do |config|
  config.order = :random
  config.mock_framework = :rr

  config.before :example do
    Yell::Repository.loggers.clear

    Dir[fixture_path + '/*.log'].each { |f| File.delete(f) }
  end

  config.after :example do
    Timecop.return # release time after each test
  end

  private

  def fixture_path
    File.expand_path('fixtures', File.dirname(__FILE__))
  end
end
