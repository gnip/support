## Compliance API - Ruby client

### Gnip Compliance API

To ensure that the Twitter user's voice is continually respected, Gnip's customers are obligated to maintain compliant data stores... meaning that requests to delete or otherwise alter data are acted on and propagated through the customer's data analysis framework. To enable customers to comply, Gnip provides aa API endpoint from which all compliance data related to a customer's account can be regularly requested. A full description of the [Compliance API](http://support.gnip.com/apis/compliance_api/) can be found at the [Gnip support site](http://support.gnip.com).

The purpose of this example code is to illustrate how the Compliance API works and provide a starting place for your custom development. With luck it provides the functionality you need 'off-the-shelf.' Most likely you'll decide to extend and customize its behavior. Maybe you want to write Compliance API data to a database.  Maybe you want to wrap a user-interface around this.

### So, what does this Compliance API client do?

This Ruby app helps automate real-time requests to the Compliance API. This client will implement the recommended practice of querying the API every ten minutes, with a delay of at least 5 minutes between the end of the time interval and the current time. 

A common use-case of this client will be to simply execute it, have it pick up where it last left off, quickly backfill until it catches up to realtime, then manage Compliance API requests every ten minutes. 

It supports two operational modes:

* One-time 'backfill' mode:
   * When a start-time __and__ end-time are provided, the client will manage all Compliance API requests to cover that period.
   * The app will run in an __one-time__ fashion. When those requests are finished, the app exits. 
   * Start-time __and__ end-time parameters can be provided with a configuration file or via the command-line.
   
* 'Realtime' mode: 
   * If no end-tme is provided, the client will start in a 'realtime' mode. 
   * In this mode, the client will make as many 10-minute Compliance API requests it takes to catch up to most recent available ten-minute period (ending at least five minutes ago).
   * Once the Compliance data is caught up, the app continues to run, making Compliance API requests every ten minutes. 
   * Start-time parameter can be provided with a configuration file or via the command-line. 
 
    **_All timestamps should be in the UTC timezone._**

    _Note that if only an end-time is specified, and error will occur._

Currently, Compliance API output can be written to a 'outbox' directory. This directory can be specified in the client configuration file or via the command-line. See below for details on output directories and naming convention.

###Getting started

First you should have access to the Gnip Compliance API. This can be tested with a simple cURL command:

```
   curl -v --compressed -u<USER_NAME> \
    "https://compliance.gnip.com:443/accounts/<ACCOUNT_NAME>/publishers/twitter \
    ?fromDate=<YYYYMMDDHHMM>&toDate=<YYYYMMDDHHMM>"
```

Second, have the following files in a directory of your choice:

* __compliance_api.rb__: the 'main' client program that is excuted with various options (see below).
* __pt_restful.rb__: a common-code HTTP helper class currently based on the standard Ruby net/https gem.
* __pt_logging__: a common-code Logger class currently based on the Ruby 'logging' gem.
* __config.yaml__: Compliance Client configuration file. This file can have any path and file name (needs to be a YAML file however) when you pass that information in as a command-line parameter.

###Client Configuration

This client application uses a [YAML](http://www.yaml.org/) configuration file for setting required account and optional product information. The configutation file can also be used to set other optional settings that affect client behavior, such as output and logging details.

By default the application looks in its local directory for a ```config.yaml file```. The configuration path and file name can also be passed in via the command-line:
   ```$ruby compliance_api.rb -c "/configs/api/compliance/config.yaml" ```

As discussed above, start and end time parameters determine the execution behavior of the client application. These time parameters can be specified in the configuration file or passed in via the command-line. More information on their use, and the variety of formats supported for specifying timestamps, is included in the next section.

####Configuration details:

  * Account information: __account_name__, __user_name__, and __password__/__password_encypted__ for authentication.
  * Product details: __product__, __stream_type__, and __label__. These are *optional*, but they enable retrieving Compliance data for specific data products/streams. *If you have a common data store of Twitter data, it is recommended that you make API requests at the account level by not specifying these parameters.*
  * Application options:
      * __query_length_in_seconds__: Duration of the Compliance API request, in seconds. The maximum period per request is 10 minutes. Defaults to 600.
      * __out_box__: Directory where Compliance datafiles are written. Defaults to ```./data```. Specified directory is created if neccessary.
      * __ignore_no_results_response__: When set to ```true``` no file is written if there are no Compliance events in API response. When set to false, a file is created even if no events occured during the requested period. Defaults to ```true```.

  * Logging. The client includes basic logging support (using the [logging](https://github.com/TwP/logging) Ruby gem), with the following options.

    * __log_file_path__: The path and file name to contain client log entries. Default to ```./compliance_api.log```.
    * __warn_level__: Logging level: :debug, :info, :warn, :error, :critical, :fatal. Defaults to ```info```.
    * __size__: The maximum size of the log file, in megabytes (MB). Default is 10 MB.
    * __keep__: The number of rolling log files to maintain. Default is 2.

See [HERE](https://github.com/jimmoffitt/rbComplianceAPI/blob/master/example_config.yaml) for an example Compliance API client configuration file.

###Command-line options

The application also provides command-line support for these parameters:

```
Usage: compliance_api [options]
    -c, --config CONFIG              Configuration file (including path) that provides account and download settings.
                                         Config files include username, password, account name and stream label/name.
    -s, --start_time START           UTC timestamp for beginning of Search period.
                                           Specified as YYYYMMDDHHMM, "YYYY-MM-DD HH:MM", YYYY-MM-DDTHH:MM:SS.000Z or use ##d, ##h or ##m. If set to 'file', a local 'start_time.dat' file is used to track Compliance API calls.
    -e, --end_time END               UTC timestamp for ending of Search period.
                                        Specified as YYYYMMDDHHMM, "YYYY-MM-DD HH:MM", YYYY-MM-DDTHH:MM:SS.000Z or use ##d, ##h or ##m.
    -o, --outbox OUTBOX              Optional. Triggers the generation of files and where to write them.
    -h, --help                       Display this screen.

```

##Specifying Start and End Times

* __start_time__ and __end_time__ are specified in __UTC__. All timestamps included in the Compliance API responses are in __UTC__.
* Search start-and end-time can be specified in several ways: 
    * standard PowerTrack timestamps (YYYYMMDDHHMM).
    * ISO 8061/Twitter timestamps (2013-11-15T17:16:42.000Z), as "YYYY-MM-DD HH:MM".
    * With simple notation indicating the number of minutes (30m), hours (12h) and days (14d).

####Important notes
* Specifying both a start-time __and__ end-time will run the client in a __one-time__ 'backfill' mode. The client will manage all Compliance API requests to cover that period, then exit. 
* Specifying only a start-time will run the client app in a 'realtime' mode. The app continues to run, making Compliance API requests every ten minutes. 
* If no start-time is provided, the app will use a 'last time' file mechanism to determine its start-time. If no 'last time' file is found, the app will wait ten minutes and then begin making Compliance API requests every ten minutes.
* If only an end-time is provided, an error will be thrown.

This Compliance API client writes a 'last time' file in its local directory after every successful Compliance API request. If no 'start-time' is provided when the client starts, it will be set to the timestamp found in the 'last time' file. If the client starts with no start-time parameters, and the 'last time' file is not found, the client will set the 'start-time' to the current time, wait ten minutes, and begin making Compliance API requests.  A 'last time' file is a simple (UTF-8) text file that contains a ```YYYY-MM-DD HH:MM``` timestamp. 

##Output

Currently, this client simply writes the Compliance API responses as json text files.

The client manages the creating of a time-stamped hierachary of output folders.



```
 storage: files #options: files, standard_out, database (not implemented yet) 
 out_box: ./data
 ignore_no_results_response: true
```

These details are implemented in the ```write_data``` method. 

##Example Usage

Configuration and rule details can be specified by passing in files or specifying on the command-line, or a combination of both.  Here are some quick example:

* Start Compliance API client and continue running until terminated: 
  *  ```$ruby compliance_api.rb ``` with no __start_time__ or __end_time__ set in configuration file.
  *  Note: application will wait 15-minutes and begin making 10-minute requests every 10 minutes.

* Begin real-time fetch of Compliance API data, starting 24 hours ago: 
  * ```$ruby compliance_api.rb -s 24h```  (Note ```-s 1d``` and ```-s 1440m``` are equivalent start time parameters.) 

* Backfill a 12-hour period:
  * ```$ruby compliance_api.rb -s '2015-01-01 00:00' -e '2015-01-01 12:00' ```









