require 'bundler/gem_tasks'

# Run stuff in the examples folder
desc 'Run examples'
task :examples do
  require 'benchmark'
  require File.join(File.dirname(__FILE__), 'lib', 'yell')

  logger = Yell.new :stdout,
                    format: Yell::NoFormat,
                    colors: true

  Dir['./examples/*.rb'].each do |file|
    logger.debug <<-EOS

##
# Example:
#   #{file}
# #{'-' * 80}
EOS

    require file
  end
end
