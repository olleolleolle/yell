# encoding: utf-8
module Yell #:nodoc:
  # Raised when a silencer preset was not found.
  class SilencerNotFound < StandardError
    def message
      "Could not find a preset for #{super.inspect}"
    end
  end

  # The +Yell::Silencer+ is your handy helper for ignoring unwanted messages.
  class Silencer
    PRESETS = {
      # Rails
      assets: [%r{\AStarted GET "\/assets}, %r{\AServed asset/, /\A\s*\z}]
    }.freeze

    def initialize(*patterns)
      @patterns = patterns.dup
    end

    # Add one or more patterns to the silencer
    #
    # @example
    #   add( 'password' )
    #   add( 'username', 'password' )
    #
    # @example Add regular expressions
    #   add( /password/ )
    #
    # @return [self] The silencer instance
    def add(*patterns)
      patterns.each { |pattern| add!(pattern) }

      self
    end

    # Clears out all the messages that would match any defined pattern
    #
    # @example
    #   call(['username', 'password'])
    #   #=> ['username]
    #
    # @return [Array] The remaining messages
    def call(*messages)
      return messages if @patterns.empty?

      messages.reject { |m| matches?(m) }
    end

    # Get a pretty string
    def inspect
      "#<#{self.class.name} patterns: #{@patterns.inspect}>"
    end

    # @private
    attr_reader :patterns

    private

    def add!(pattern)
      @patterns |= fetch(pattern)
    end

    def fetch(pattern)
      case pattern
      when Symbol then PRESETS[pattern] || raise(SilencerNotFound, pattern)
      else [pattern]
      end
    end

    # Check if the provided message matches any of the defined patterns.
    #
    # @example
    #   matches?('password')
    #   #=> true
    #
    # @return [Boolean] true or false
    def matches?(message)
      @patterns.any? { |p| message.respond_to?(:match) && message.match(p) }
    end
  end
end
