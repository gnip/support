#!/usr/bin/env python
__author__ = "Jeff Kolb"

import ConfigParser
import sys
import time
import os
import copy
import logging
import logging.handlers
import base64
import datetime
import time
import gzip
import requests

class ComplianceApiClient():
    """
    This class needs to make recurring HTTP GET requests to the 
    Gnip compliance API, and store the results in an appropriate location.
    """
    def __init__(self
        , _endpoint_url
        , _process_name
        , _user_name
        , _password
        , _file_path
        , compress_output=True
    ):
        logr.info("ComplianceApiClient started")
        self.compress_output = compress_output
        logr.info("Compress output: " + str(self.compress_output))
        self.process_name = _process_name
        self.endpoint_url = _endpoint_url
        logr.info("Collection starting for endpoint" + self.endpoint_url)
        self.file_path = _file_path 
        logr.info("Storing data in path " + file_path)

        self.headers = { "Accept": "application/json",  
            "Content-Type" : "application/json",
            "Accept-Encoding" : "gzip",
            "Authorization" : "Basic %s"%base64.encodestring(
                "%s:%s"%(_user_name, _password))  }

    def trim_to_minute(self, dt):
        """
        Trim a datetime object to minute precision
        """
        dt = dt.replace(second = 0)
        dt = dt.replace(microsecond = 0)
        return dt

    def run(self, run_args):
        """
        Set up start and stop time, and make connection.

        We allow three configurations of the initial query: 
        
        1) Default: the query is made from [15 minutes ago] through [5 mintues ago].

        2) By setting the "start_time_offset_in_seconds" parameter of the "run" block,
        the start time of the first query is given by the current time
        minus the offset.

        3) By setting the "start_time" parameter of the "run" block,
        the start time of the first query can be set manually.
        """

        query_length = 10
        if "query_length" in run_args:
            query_length = int(run_args["query_length"])
       
        stop_time = datetime.datetime(2050,12,31,23,59)
        if "stop_time" in run_args:
            stop_time = datetime.datetime.strptime(run_args["stop_time"],"%Y%m%d%H%M") 

        # determine start/stop time of initial query
        if "time_offset_in_seconds" in run_args:
            time_offset = datetime.timedelta(seconds=int(run_args["time_offset_in_seconds"])) 
            query_stop_time = self.trim_to_minute(datetime.datetime.utcnow() - time_offset) 
            query_start_time = query_stop_time - datetime.timedelta(0,query_length*60)
        elif "start_time" in run_args:
            query_start_time = datetime.datetime.strptime(run_args["start_time"],"%Y%m%d%H%M") 
            query_stop_time = query_start_time + datetime.timedelta(0,query_length*60) 
        else:
            query_stop_time = datetime.datetime.utcnow() - datetime.timedelta(0,300)
            query_start_time = query_stop_time - datetime.timedelta(0,query_length*60)
       
        # loop until we reach the stop_time
        while True:
            
            # we musn't query closer than 5 minutes to present time
            if datetime.datetime.utcnow() < query_stop_time + datetime.timedelta(0,300) : 
                logr.debug("sleeping: {} < {} + {}".format(datetime.datetime.utcnow(), query_stop_time, datetime.timedelta(0,300)))
                time.sleep(int(run_args["sleep_time_in_seconds"]))
            else:     
                if query_stop_time > stop_time: 
                    break
                self.get_data(query_start_time, query_stop_time, run_args) 
                query_start_time = copy.deepcopy(query_stop_time)
                query_stop_time = query_start_time + datetime.timedelta(0,query_length*60)
        
        self.get_data(query_start_time, stop_time, run_args)
        logr.info("Process has finished; stop time has been reached.")


    def get_data(self, start_time, stop_time, run_args): 
        """
        Make the request; write the response.
        """
        logr.info("Collecting data from {} to {}".format(start_time.strftime("%Y%m%d%H%M"),stop_time.strftime("%Y%m%d%H%M")))
        params = {
                "fromDate" : start_time.strftime("%Y%m%d%H%M"),
                "toDate" : stop_time.strftime("%Y%m%d%H%M")
        }
        for param_name in ["product","streamType","name"]:
            if param_name in run_args:
                params[param_name] = run_args[param_name]

        logr.debug("request parameters are: {}".format(params))

        request = requests.get(self.endpoint_url
                , headers=self.headers
                , params = params
                ) 
        
        # write the data to disk
        file_path = "/".join([
            self.file_path,
            "%d"%start_time.year,
            "%02d"%start_time.month,
            "%02d"%start_time.day,
            "%02d"%start_time.hour 
            ])
        try:
            os.makedirs(file_path) 
        except OSError:
            pass
        
        file_name = self.process_name + "_"
        file_name += "-".join([
                "%d"%start_time.year,
                "%02d"%start_time.month,
                "%02d"%start_time.day])
        file_name += "_%02d%02d"%(start_time.hour, start_time.minute)

        if self.compress_output:
            file_name += ".json.gz" 
            open_function = gzip.open
        else:
            open_function = open
            file_name += ".json" 
        
        f = open_function(file_path + "/" + file_name,"w") 
        f.write(request.text)
        
if __name__ == "__main__":
    logr = logging.getLogger("GnipComplianceLogger")
    
    if "GNIP_CONFIG_FILE" in os.environ:
        config_file_name = os.environ["GNIP_CONFIG_FILE"]
    else:
        config_file_name = "./gnip.cfg"
        if not os.path.exists(config_file_name):
            print "No configuration file found."
            sys.exit()
    config = ConfigParser.ConfigParser()
    config.read(config_file_name)
    
    # set up connection configuration
    if config.has_section("auth"):
        username = config.get("auth","username")
        password = config.get("auth","password")
    elif config.has_section("creds"):
        username = config.get("creds","username")
        password = config.get("creds","password")
    else:
        logr.error("No credentials found")
        sys.exit()
    endpoint_url = config.get("endpoint", "endpoint_url")
   
    # processing options
    file_path = config.get("proc", "file_path")
    if config.has_option("proc", "compress_output"):
        compress_output = config.getboolean("proc", "compress_output")  
    else:
        compress_output = True
    if config.has_option("proc", "process_name"):
        process_name = config.get("proc", "process_name")  
    else:
        process_name = "Compliance"
    
    # configure logger 
    log_file_path = config.get("logging","log_file_path")
    if config.has_option("logging","log_level"):
        log_level = config.get("logging", "log_level")
    else:
        log_level = "INFO"
    logr = logging.getLogger("GnipComplianceLogger")
    rotating_handler = logging.handlers.RotatingFileHandler(
            filename=log_file_path + "/%s-log"%process_name,
            mode="a", maxBytes=2**24, backupCount=5)
    rotating_handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(funcName)s %(message)s"))
    logr.setLevel(getattr(logging,log_level))
    logr.addHandler(rotating_handler)
    logr.debug("reading configuration from {}".format(config_file_name))

    # configure run mode
    run_args = {}
    if config.has_section("run"): 
    
        if config.has_option("run", "start_time_offset_in_seconds") and config.has_option("run", "start_time"):
            sys.stderr.write('Must not set both "start_time_offset_in_seconds" and "start_time" in the "run" block!\n') 
            sys.exit(1)
        if config.has_option("run", "start_time_offset_in_seconds"):
            run_args["time_offset_in_seconds"] = config.get("run", "start_time_offset_in_seconds") 
            if int(run_args["time_offset_in_seconds"]) < 300:
                sys.stderr.write("run:time offset must be > 5 minutes!")
                sys.exit(1)
        if config.has_option("run", "start_time"):
            run_args["start_time"] = config.get("run", "start_time") 
        if config.has_option("run", "stop_time"):
            run_args["stop_time"] = config.get("run", "stop_time") 
        
        if config.has_option("run", "query_length_in_minutes"): 
            run_args["query_length"] = config.get("run", "query_length_in_minutes")  
            if int(run_args["query_length"]) > 10:
                sys.stderr.write("Query length must be <= 10 minutes.\n")
        
        if config.has_option("run", "sleep_time_in_seconds"):
            run_args["sleep_time_in_seconds"] = config.get("run", "sleep_time_in_seconds")
        else:
            run_args["sleep_time_in_seconds"] = 10

        if config.has_option("run", "gnip_product"):
            run_args["product"] = config.get("run", "gnip_product")
        if config.has_option("run", "gnip_stream_type"):
            run_args["streamType"] = config.get("run", "gnip_stream_type")
        if config.has_option("run", "gnip_stream_name"):
            run_args["name"] = config.get("run", "gnip_stream_name")


    # ok, do it
    client = ComplianceApiClient(endpoint_url
            , process_name
            , username
            , password
            , file_path
            , compress_output=compress_output
    )
    client.run(run_args)

    

