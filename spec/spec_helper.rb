$LOAD_PATH.unshift File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['YELL_ENV'] = 'test'

require 'rspec/core'
require 'rspec/expectations'
require 'rr'
require 'timecop'

begin
  require 'coveralls'
  require 'simplecov'

  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter[
      Coveralls::SimpleCov::Formatter,
      SimpleCov::Formatter::HTMLFormatter
    ]
    add_filter 'spec'
  end
rescue LoadError
  $stderr.puts 'Not running coverage'
end

require 'yell'

RSpec.configure do |config|
  config.order = :random
  config.mock_framework = :rr

  config.before :example do
    Yell::Repository.loggers.clear

    Dir[fixture_path.join('*.log')].each { |f| File.delete(f) }
  end

  config.after :example do
    Timecop.return # release time after each test
  end

  private

  def fixture_path
    path = File.expand_path('fixtures', File.dirname(__FILE__))
    Pathname.new(path)
  end
end
