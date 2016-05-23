require 'logger'

class Logger #:nodoc:
  def level_with_yell=(level)
    self.level_without_yell = Integer(level)
  end
  alias level_without_yell= level=
  alias level= level_with_yell=

  def add_with_yell(severity, message = nil, progname = nil, &block)
    add_without_yell(Integer(severity), message, progname, &block)
  end
  alias add_without_yell add
  alias add add_with_yell
end
