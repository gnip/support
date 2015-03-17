#!/usr/bin/env ruby
__author__ = "Jim Moffitt"

#TODOs:
#     [X] Have mechanism to persist endpoint, for subsequent run....? last_run.dat file? Rewrite yaml file?
#     [X] Logging?
#     [] Filling all oComp attributes?
#     [] encrypted password
#     [X] Start compliance calls
#     [X] Handle output
#     [X] Ignore empty result responses

require 'optparse'
require 'base64'
require 'time'
require 'json'
require 'logging'

#Some helper classes. 
require_relative './pt_restful'
require_relative './pt_logging'

class ComplianceAPIClient

  attr_accessor :http, #need a HTTP object to make requests of.
                :urlCompliance, #End-point.

                :account_name, :user_name,
                :password, :password_encoded, #System authentication.
                :publisher, #Twitter only.
                :product, :stream_type, :label, #These are currently not in Compliance URI.

                :run_mode,
                :start_time, :end_time, #Of entire period to fetch Compliance data for.

                :use_start_file, :start_time_file,
                :query_length, #in seconds.

                :storage,
                :out_box,
                :ignore_no_results_response,
                :compress_files,

                :logger,
                :warn_level,
                :log_file_path


  #Can only ask for Compliance data from 5-minutes ago.
  COMPLIANCE_MIN_LATENCY = 300 #Seconds.
  SLEEP_TIME = 30 #Seconds.

  def initialize

    #class variables.
    @@base_url = "https://compliance.gnip.com/accounts/"

    #Initialize stuff.

    #Defaults.
    @publisher = "twitter"
    @start_time_file = './start_time.dat'
    @query_length = 600

    @storage = "files" #No other option implemented yet.
    @out_box = "./data"
    @compressed_files = true

    @log_file_path = './compliance_api.log'
    logger = Logging.logger(STDOUT)
    logger.level = :info


    #Set up a HTTP object.
    #TODO: OR use Search API demo objects...
    @http = PtRESTful.new

  end

  def logger=(logger)
    @logger = logger
  end

  def write_start_time(request_end)
    #Take the current end_time and write it out to start_time_file.
    logger.debug("Writing start_time.dat file with: #{request_end.strftime('%F %H:%M')}")
    f = File.open(@start_time_file, 'w')
    f.write(request_end.strftime('%F %H:%M'))
    f.close
  end

  #Manages calls to the Compliance API, using start and end times...
  #Timestamps arrive here in the YYYYMMDDHHMM format, get cast to Time objects for doing math,
  #then cast back to YYYYMMDDHHMM for request method. 
    
  def run
    @logger.debug "Running..."
    success = false
    
    request_start = Time.new
    request_end = Time.new
    
    #Convert time strings to Time objects, for math fun.
    if !@start_time.nil? then 
      @start_time =  Time.parse("#{@start_time}Z")
    end

    if !@end_time.nil? then
      @end_time =  Time.parse("#{@end_time}Z")
    end
    

    #If providing both a start and end time, then this is a 'one-time' 'backfill' run. Assuming period spans more
    #than one request limit, multiple calls are made, then the app exits.
    if !@start_time.nil? and !@end_time.nil? then

      #Check end_time, and correct if neccessary TODO: doc
      @end_time = Time.now.utc - COMPLIANCE_MIN_LATENCY if @end_time > Time.now.utc - COMPLIANCE_MIN_LATENCY

      #Set up initial request.
      request_start =  @start_time
      request_end = @start_time + @query_length
      
      #Check end_time, and correct if neccessary TODO: doc
      @request_end = Time.now - COMPLIANCE_MIN_LATENCY if request_end > Time.now.utc - COMPLIANCE_MIN_LATENCY

      #Manage requests for this backfill period.
      while true
        success = make_request(request_start, request_end)
        
        if success then 
          request_start = request_end
          request_end = request_start + @query_length
          if request_end > @end_time then
            request_end = @end_time
          end
        
          if request_start >= @end_time then
            break
          end

          request_end = Time.now.utc - COMPLIANCE_MIN_LATENCY if request_end > Time.now.utc - COMPLIANCE_MIN_LATENCY
        end  
      end
    else #Realtime mode.

      request_start = @start_time
      request_end = @start_time + @query_length

      #Hold-off if needed before initial run.
      
      logger.info "Too early to run, waiting..." if Time.now.utc < (request_end + COMPLIANCE_MIN_LATENCY)
      while Time.now.utc < (request_end + COMPLIANCE_MIN_LATENCY)
        logger.debug("Too early to run, sleeping #{SLEEP_TIME} seconds...")
        #puts "Holding off #{SLEEP_TIME} seconds..."
        sleep SLEEP_TIME
      end

      while true
        success = make_request(request_start, request_end)

        if success then
          request_start = request_end
          request_end = request_start + @query_length
        end

        logger.info "Waiting to make next request..." if Time.now.utc < (request_end + COMPLIANCE_MIN_LATENCY)
        while Time.now.utc < (request_end + COMPLIANCE_MIN_LATENCY)
          logger.debug("Holding off #{SLEEP_TIME} seconds...")
          #puts "Holding off #{SLEEP_TIME} seconds..."
          sleep SLEEP_TIME
        end
        
      end
    end
  end

  def make_request(request_start, request_end)

    @urlCompliance = @http.getComplianceURL(@account_name)

    parameters = {}
    parameters['fromDate'] =  get_date_string(request_start)
    parameters['toDate'] =  get_date_string(request_end)
    parameters['product'] = @product unless @product.nil?
    parameters['stream_type'] = @stream_type unless @stream_type.nil?
    parameters['label'] = @label unless @label.nil?

    headers = {}
    headers['Content-Type'] = 'application/json'
    headers['accept'] = 'application/json'
    #headers['Accept-Encoding'] = 'gzip'

    logger.info("Calling Compliance API with GET(#{parameters.to_s}")
    response = @http.GET(parameters, headers)

    data = response.body

    if response.code != "200" then
      logger.error("Error #{response.code} response code from Compliance API.")
      return false
    else
      if @use_start_file then
        write_start_time request_end
      end

      write_data data, request_start, request_end
    end
    
    return true

  end

  def write_data(response, start_time, end_time)
    
    if @ignore_no_results_response then #confirm that there are some results...
      if JSON.parse(response)['summary']['totalResults'] == 0 then 
        return
      end
    end    

    #Cast timestamps into Time objects.
    begin
      st = Time.parse("#{start_time}").utc
      et = Time.parse("#{end_time}").utc
    rescue => e
      logger.error("Error creating Time objects: #{e.message} | #{e.to_s}")
    end

    #Create output folders.
    begin
      file_path = "#{@out_box}/#{st.year}/#{'%02d' % st.month}/#{'%02d' % st.day}/#{'%02d' % st.hour}"
      FileUtils.mkdir_p(file_path)
    rescue => e
      logger.error("Error creating output folder: #{e.message} | #{e.to_s}")
    end

    #Create output file.
    begin
      file_name = "compliance-#{st.year}-#{'%02d' % st.month}-#{'%02d' % st.day}-#{'%02d' % st.hour}-#{'%02d' % st.min}.json"
      f = File.open("#{file_path}/#{file_name}",'w+')

      logger.debug("Writing output file #{file_name}")

      f.write(response)
      f.close
    rescue => e
      logger.error("Error creating output folder: #{e.message} | #{e.to_s}")
    end
  end

  #Load in the configuration file details, setting many object attributes.
  def get_app_config(config_file)

    #logger.debug 'Loading configuration file.'

    config = YAML.load_file(config_file)

    #Config details.

    #Parsing account details if they are provided in file.
    if !config["account"].nil? then
      if !config["account"]["account_name"].nil? then
        @account_name = config["account"]["account_name"]
      end

      if !config["account"]["user_name"].nil? then
        @user_name = config["account"]["user_name"]
      end

      if !config["account"]["password"].nil? or !config["account"]["password_encoded"].nil? then
        @password_encoded = config["account"]["password_encoded"]

        if @password_encoded.nil? then #User is passing in plain-text password...
          @password = config["account"]["password"]
          @password_encoded = Base64.encode64(@password)
        end
      end
    end

    @http.user_name = @user_name
    @http.password_encoded = @password_encoded

    #Product configuration, all are optional.
    if !config['product'].nil? then
      @product = config['product']['product']
      @stream_type = config['product']['stream_type']
      @label = config['product']['label']
    end

    #App settings.
    @start_time = config['app']['start_time']
    @end_time = config['app']['end_time']
    
    @query_length = config['app']['query_length_in_seconds']
    @storage = config['app']['storage']

    begin
      @out_box = checkDirectory(config["app"]["out_box"])
    rescue
      @out_box = "./data"
    end

    begin
      @ignore_no_results_response = config["app"]["ignore_no_results_response"]
    rescue
      @ignore_no_results_response = false
    end

    begin
      @compress_files = config["app"]["compress_files"]
    rescue
      @compress_files = false
    end

    @log_file_path = config['app']['log_file_path']
    

# Future database support?
#     if @storage == "database" then #Get database connection details.
#       db_host = config["database"]["host"]
#       db_port = config["database"]["port"]
#       db_schema = config["database"]["schema"]
#       db_user_name = config["database"]["user_name"]
#       db_password = config["database"]["password"]
#
#       @datastore = PtDatabase.new(db_host, db_port, db_schema, db_user_name, db_password)
#       @datastore.connect
#     end
#
  end

  #TODO: implement. 
  def check_config

    config_ok = true

    if @user_name.nil? then
        p 'Error: no user_name.'
        return false
    end

    if @password.nil? and @password_encoded.nil? then
      p 'Error: no password.'
      return false
    end

    if !@end_time.nil? and @start_time.nil? then
      p 'Error: only end_time provided. When setting end time, a start time must also be provided.'
      return false
    end

    return config_ok
  end

  #Helper function to return encrypted password.
  def encrypt_password(password)
    puts password 
  end
  
  def get_date_string(time)
    return time.year.to_s + sprintf('%02i', time.month) + sprintf('%02i', time.day) + sprintf('%02i', time.hour) + sprintf('%02i', time.min)
  end

  #Takes a variety of string inputs and returns a standard PowerTrack YYYYMMDDHHMM timestamp string.
  def set_date_string(input)

    now = Time.new.utc
    date = Time.new.utc

    #Handle minute notation.
    if input.downcase[-1] == "m" then
      date = now - (60 * input[0..-2].to_f)
      return get_date_string(date)
    end

    #Handle hour notation.
    if input.downcase[-1] == "h" then
      date = now - (60 * 60 * input[0..-2].to_f)
      return get_date_string(date)
    end

    #Handle day notation.
    if input.downcase[-1] == "d" then
      date = now - (24 * 60 * 60 * input[0..-2].to_f)
      return get_date_string(date)
    end

    #Handle PowerTrack format, YYYYMMDDHHMM
    if input.length == 12 and numeric?(input) then
      return input
    end

    #Handle "YYYY-MM-DD 00:00"
    if input.length == 16 then
      return input.gsub!(/\W+/, '')
    end

    #Handle ISO 8601 timestamps, as in Twitter payload "2013-11-15T17:16:42.000Z"
    if input.length > 16 then
      date = Time.parse(input)
      return get_date_string(date)
    end

    logger.info("ERROR: could not parse 'start_time'. ")
    return 'Error, unrecognized timestamp.'

  end

  def get_logger(config_file=nil)

    logging = PTLogging.new
    logging.get_config(config_file)
    @logger = logging.get_logger
    logging.name = 'compliance_api'

  end

end

#-------------------------------------------------------------------------------------------------------------------
#Options:
#  Pass in nothing, look locally for configuration file.
#  Pass in configuration file.
#  Pass in selected parameters on command-line:
#       outbox
#       start time
#       end time

#Example command-lines:
# $ruby ./compliance_api.rb
# $ruby ./compliance_api.rb -c "./ComplianceConfig.yaml"
# $ruby ./compliance_api.rb -c "./ComplianceConfig.yaml" -s "2013-10-18 06:00" -e "2013-10-20 06:00"
# $ruby ./compliance_api.rb -s "2013-10-18 06:00" -e "2013-10-20 06:00"

#Compliance API object init has base-line defaults.
#Next looks for local config.yaml, and overwrites with anything provided there.
#Finally, takes passed in command-line parameters, overwriting


#-------------------------------------------------------------------------------------------------------------------

#=======================================================================================================================
if __FILE__ == $0  #This script code is executed when running this file.

  oComp = ComplianceAPIClient.new()
  oComp.start_time_file = './start_time.dat'

  #Handle any passed-in command-line parameters.
  if ARGV.length > 0 then

    OptionParser.new do |o| #Process any parameters passed-in via command-line.

      #Passing in a config file.... Or you can set a bunch of parameters.
      o.on('-c CONFIG', '--config', 'Configuration file (including path) that provides account and download settings.
                                         Config files include username, password, account name and stream label/name.') { |config| $config = config}

      #The following parameters need to be provided by configuration file. Command-line not yet supported.
      #Basic Authentication.
      #o.on('-u USERNAME','--user', 'User name for Basic Authentication.  Same credentials used for console.gnip.com.') {|username| $username = username}
      #o.on('-p PASSWORD','--password', 'Password for Basic Authentication.  Same credentials used for console.gnip.com.') {|password| $password = password}

      #Search URL, based on account name.
      #o.on('-a ADDRESS', '--address', 'Either Compliance API URL, or the account name which is used to derive URL.') {|address| $address = address}
      #o.on('-n NAME', '--name', 'Label/name used for Stream API. Required if account name is supplied on command-line,
      #                               which together are used to derive URL.') {|name| $name = name}

      #TODO: pass in product/stream details?
      
      #Period of search.  Defaults to end = Now(), start = Now() - 30.days.
      o.on('-s START', '--start_time', "UTC timestamp for beginning of Search period.
                                           Specified as YYYYMMDDHHMM, \"YYYY-MM-DD HH:MM\", YYYY-MM-DDTHH:MM:SS.000Z or use ##d, ##h or ##m. If set to 'file', a local 'start_time_saved.dat' file is used to track Compliance API calls.") { |start_time| $start_time = start_time}
      o.on('-e END', '--end_time', "UTC timestamp for ending of Search period.
                                        Specified as YYYYMMDDHHMM, \"YYYY-MM-DD HH:MM\", YYYY-MM-DDTHH:MM:SS.000Z or use ##d, ##h or ##m.") { |end_time| $end_time = end_time}

      o.on('-o OUTBOX', '--outbox', 'Optional. Triggers the generation of files and where to write them.') {|outbox| $outbox = outbox}

      #Help screen.
      o.on( '-h', '--help', 'Display this screen.' ) do
        puts o
        exit
      end

      o.parse!

    end
  end

  #Load configuration file.
  config_file = "./config.yaml" #Default location and name.
  if !$config.nil? then
    config_file = $config #Or overwritten from command-line.
  end

  #Set up Logger.
  oComp.get_logger(config_file)
  oComp.logger.info "Compliance API client started."

  oComp.get_app_config(config_file)

  #We need to end up with PowerTrack timestamps in YYYYMMDDHHmm format.
  #If numeric and length = 12 then we are all set.
  #If ISO format and length 16 then apply o.gsub!(/\W+/, '')
  #If ends in m, h, or d, then do some time.add math

  read_start_time = false

  #Handle start date.
  #First see if it was passed in
  if !$start_time.nil? then
    oComp.start_time = oComp.set_date_string($start_time)
  end

  #Handle end date.
  #First see if it was passed in
  if !$end_time.nil? then
    oComp.end_time = oComp.set_date_string($end_time)
  end

  if oComp.start_time.nil? then
    oComp.use_start_file = true
    if !File.exist?(oComp.start_time_file)
      oComp.start_time = oComp.set_date_string(Time.now.utc.to_s)
    else
      start_time_dat = File.read(oComp.start_time_file)
      oComp.start_time = oComp.set_date_string(start_time_dat)
    end
  end

  if oComp.check_config then
    oComp.run
  else
    p 'Problem with configuration. Please check and retry.'
    logger.error 'Problem with configuration. Not running...'
  end
end

