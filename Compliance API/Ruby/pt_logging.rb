require 'logging'

class PTLogging

  attr_accessor :logger, :name, :log_file_path, :warn_level, :size, :keep, :roll_by

  def initialize
    Logging.init :debug, :info, :warn, :error, :critical, :fatal
    @name = 'logger'
    @logger = Logging.logger(@name)
    @log_file_path = "./#{@name}.log"
    @warn_level = 'info'
    @size = 10 #MB
    @keep = 2
  end

  def get_logger
    @logger = Logging.logger(@name)
    @logger.level = @warn_level
    layout = Logging.layouts.pattern(:pattern => '[%d] %-5l: %m\n')
    #Always write to a rolling file.
    default_appender = Logging::Appenders::RollingFile.new 'default', \
         :filename => @log_file_path, :size => (@size * 1024), :keep => @keep, :safe => true, :layout => layout
    #Comment this if you don't want log statements written to system out.
    @logger.add_appenders(default_appender, Logging.appenders.stdout)
    return @logger
  end

