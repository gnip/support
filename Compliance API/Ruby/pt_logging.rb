require 'logging'

class PTLogging

  attr_accessor :logger,
                :name, :log_file_path,
                :warn_level,
                :size, :keep, :roll_by

  def initialize
    Logging.init :debug, :info, :warn, :error, :critical, :fatal
    @name = 'logger'
    @logger = Logging.logger(@name)
    @log_file_path = "./#{@name}.log"
    @warn_level = 'info'
    @size = 10 #MB
    @keep = 2
  end

  def name=(name)
    @name = name
    @log_file_path = "./#{@name}.log"
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

  #Load in the configuration file details, setting many object attributes.
  def get_config(config_file)

    #look locally, if not there then look in ./config folder/
    if !File.exist?(config_file) then
     config_file = "./config/#{config_file}"
    end

    #TODO: no file, load defaults and give warning.

    config = {}
    config = YAML.load_file(config_file)

    #Config details.
    @log_file_path = config['logging']['log_file_path']
    @warn_level = config['logging']['warn_level']
    if @warn_level.nil? then
      @warn_level = 'info'
    end
    @size = config['logging']['size']
    @keep = config['logging']['keep']
  end

end