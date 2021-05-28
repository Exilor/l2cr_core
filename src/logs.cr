require "colorize"

module Logs
  extend self

  private LOGGERS = Concurrent::Map(Symbol, Logger).new

  def [](log_name : Symbol) : Logger
    LOGGERS.store_if_absent(log_name) do
      time = Time.local.to_s("%Y-%m-%d")
      Dir.mkdir_p("#{Dir.current}/logs/#{log_name}/")
      file = File.open("#{Dir.current}/logs/#{log_name}/#{time}.log", "a")
      logger = Logger.new(file, progname: log_name.to_s.capitalize)
      logger.formatter = Logger::Formatter.new do |severity, time, subject, msg, io|
        io << severity.to_s[0]
        time.to_s(io, " [%H:%M:%S] [")
        io << subject << "] " << msg
      end
      logger.level = Logger::Severity::DEBUG
      logger
    end
  end

  def debug(msg) : Nil
    return unless debug?
    msg = to_msg(msg)
    self[:general].debug(nil, msg)
    ConsoleLogger.debug(nil, msg)
  end

  def debug(subject, msg) : Nil
    return unless debug?
    msg = to_msg(msg)
    self[:general].debug(subject, msg)
    ConsoleLogger.debug(subject, msg)
  end

  def debug(subject = nil, & : ->) : Nil
    return unless debug?
    msg = to_msg(yield)
    self[:general].debug(subject, msg)
    ConsoleLogger.debug(subject, msg)
  end

  def info(msg) : Nil
    msg = to_msg(msg)
    self[:general].info(nil, msg)
    ConsoleLogger.info(nil, msg)
  end

  def info(subject, msg) : Nil
    msg = to_msg(msg)
    self[:general].info(subject, msg)
    ConsoleLogger.info(subject, msg)
  end

  def info(subject = nil, & : ->) : Nil
    msg = to_msg(yield)
    self[:general].info(subject, msg)
    ConsoleLogger.info(subject, msg)
  end

  def warn(msg) : Nil
    msg = to_msg(msg)
    self[:general].warn(nil, msg)
    ConsoleLogger.warn(nil, msg)
  end

  def warn(subject, msg) : Nil
    msg = to_msg(msg)
    self[:general].warn(subject, msg)
    ConsoleLogger.warn(subject, msg)
  end

  def warn(subject = nil, & : ->) : Nil
    msg = to_msg(yield)
    self[:general].warn(subject, msg)
    ConsoleLogger.warn(subject, msg)
  end

  def error(msg) : Nil
    msg = to_msg(msg)
    self[:error].error(nil, msg)
    self[:general].error(nil, msg)
    ConsoleLogger.error(nil, msg)
  end

  def error(subject, msg) : Nil
    msg = to_msg(msg)
    self[:error].error(subject, msg)
    self[:general].error(subject, msg)
    ConsoleLogger.error(subject, msg)
  end

  def error(subject = nil, & : ->) : Nil
    msg = to_msg(yield)
    self[:error].error(subject, msg)
    self[:general].error(subject, msg)
    ConsoleLogger.error(subject, msg)
  end

  private def to_msg(msg)
    msg.is_a?(Exception) ? msg.inspect_with_backtrace : msg
  end

  def debug? : Bool
    Config.debug
  end

  private module ConsoleLogger
    extend self

    private LOCK = Mutex.new(:Reentrant)

    {% for name, color in {debug: :cyan, info: :green, warn: :yellow, error: :red, fatal: :red, unknown: :red} %}
      def {{name.id}}(subject, msg)
        write(subject, msg, {{name.stringify[0..0].upcase}}, {{color}})
      end
    {% end %}

    private def write(subject, msg, severity_name, color) : Nil
      LOCK.synchronize do
        Time.local.to_s(STDOUT, "[%H:%M:%S] ")
        if subject
          STDOUT.print('[', subject, "] ")
        end
        STDOUT.puts(msg.colorize(color))
      end
    end
  end
end
