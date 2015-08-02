# encoding: utf-8

require 'pathname'

module Yell #:nodoc:
  # The base logger class.
  #
  # A +Yell::Logger+ instance holds all your adapters and sends the
  # log events to them if applicable. There are multiple ways of how
  # to create a new logger.
  class Logger
    include Yell::Helpers::Base
    include Yell::Helpers::Level
    include Yell::Helpers::Formatter
    include Yell::Helpers::Adapter
    include Yell::Helpers::Silencer

    # The name of the logger instance
    attr_reader :name

    # Initialize a new Logger
    #
    # @example A standard file logger
    #   Yell::Logger.new 'development.log'
    #
    # @example A standard datefile logger
    #   Yell::Logger.new :datefile
    #   Yell::Logger.new :datefile, 'development.log'
    #
    # @example Setting the log level
    #   Yell::Logger.new :level => :warn
    #
    #   Yell::Logger.new do |l|
    #     l.level = :warn
    #   end
    #
    # @example Combined settings
    #   Yell::Logger.new 'development.log', :level => :warn
    #
    #   Yell::Logger.new :datefile, 'development.log' do |l|
    #     l.level = :info
    #   end
    def initialize(*args, &block)
      options = extract_options!(*args)

      reset!(options)
      self.name = Yell.__fetch__(options, :name)

      # eval the given block
      block.arity > 0 ? block.call(self) : instance_eval(&block) if block_given?

      # default adapter when none defined
      adapters.add(:file, options) if adapters.empty?
    end

    # Set the name of a logger. When providing a name, the logger will
    # automatically be added to the Yell::Repository.
    #
    # @return [String] The logger's name
    def name=(val)
      Yell::Repository[val] = self if val
      @name = val.nil? ? "<#{self.class.name}##{object_id}>" : val

      @name
    end

    # Somewhat backwards compatible method (not fully though)
    def add(severity, *messages, &block)
      return false unless level.at?(severity)

      messages = messages
      messages << block.call unless block.nil?
      messages = silencer.call(*messages)
      return false if messages.empty?

      event = Yell::Event.new(self, severity, *messages)
      write(event)
    end

    # Creates instance methods for every log level:
    #   `debug` and `debug?`
    #   `info` and `info?`
    #   `warn` and `warn?`
    #   `error` and `error?`
    #   `unknown` and `unknown?`
    Yell::Severities.each_with_index do |s, index|
      name = s.downcase

      class_eval <<-EOS, __FILE__, __LINE__ + index
        def #{name}?; level.at?(#{index}); end  # def info?; level.at?(1); end
                                                #
        def #{name}( *m, &b )                   # def info( *m, &b )
          add(#{index}, *m, &b)                 #   add(1, *m, &b)
        end                                     # end
      EOS
    end

    # Get a pretty string representation of the logger.
    def inspect
      inspection = inspectables.map { |m| "#{m}: #{send(m).inspect}" }
      "#<#{self.class.name} #{inspection * ', '}>"
    end

    # @private
    def close
      adapters.close
    end

    # @private
    def write(event)
      adapters.write(event)
    end

    private

    def extract_options!(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      # check if filename was given as argument and put it into the options
      if [String, Pathname].include?(args.last.class)
        options[:filename] = args.pop unless options[:filename]
      end

      # set adapters
      options[:adapters] = Array(Yell.__fetch__(options, :adapters, default: []))
      options[:adapters].push(args.pop) if args.any?

      options
    end

    # Get an array of inspected attributes for the adapter.
    def inspectables
      [:name] | super
    end
  end
end
