# encoding: utf-8

require_relative '../lib/yell'

puts <<-EOS
# The extended formatting string looks like: %d [%5L] %p %h : %m.

logger = Yell.new STDOUT, :format => "%l, %m"
logger.info "Hello World!"
#=> I, Hello World!

EOS

# puts "=== actuale example ==="
puts '=' * 40
logger = Yell.new STDOUT, format: '%l, %m'
logger.info 'Hello World!'
