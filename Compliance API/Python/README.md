# Introduction

To ensure that the Twitter user's voice is respected, 
Gnip's customers are obligated to maintain compliant data stores,
meaning that requests to delete or otherwise alter data
are acted on and propagated through the customer's data 
analysis framework. To enable customers to comply, Gnip provides
an API endpoint from which all compliance data related to a customer's
account can be regularly requested. A full description of the API
can be found at the [Gnip support site](http://support.gnip.com/apis/compliance_api/).
While the linked documentation provides a complete description of a single query,
the software in this repo:

* automates the query generation
* automates the periodic submission of queries
* standardizes the data output

The recommended practice is to query the API for 10-minute time intervals, 
with a delay of at least 5 minutes between the end of the time interval 
and the current time. Missed data can be obtained with a
series of custom queries of no more than 10 minutes in length. 

To accomodate these modes of operation, this package provides a variety
of configuration options around the start, stop, and duration of the API queries.
In the default mode, queries of 10 minutes in length are automatically made when 
the stop time of the upcoming query is 5 minutes behind the current time.
In the case that the user wishes to make queries from a point in the past, 
and "catch up" to the current time, this package provides a way 
of specifying a custom start time. Queries will be automatically made
until all data is collected up to the current time.

It should be emphasized that we guarantee that the customer has received 
all compliance messages relevant to their account, 
if they have queried all times from the compliance API account activation time
through five minutes from the current time.

# Configuration

This software package uses the standard Python configuration file format,
which is parsed by the [ConfigParser](https://docs.python.org/2/library/configparser.html) module. 
The location and name of the config file can be specified with the
`GNIP_CONFIG_FILE` environment variable. Otherwise,
the config file is expected to be named `gnip.cfg`,
and to live in the directory from which the executable script (`src/GnipComplianceApiConnector.py`) is run.
A template config file can be found at `gnip_template.cfg`.


## General configuration options

Python configuration files contain hierarchical "blocks", each of which contain individual parameter names and values.

The `auth` block specifies the user's Gnip username and password 
with the following parameters: `username` and `password`.
Setting these parameters is required.

The `logging` block contains one required parameter: `log_file_path`. 
There is also an option parameter, `log_level`, 
which controls the verbosity of the logging. It must have one of the following string values: 
`DEBUG`, `INFO`, `WARNING`, `ERROR`, or `CRITICAL`. The default value is `INFO`.

The `endpoint` block contains one required parameter: `endpoint_url`, 
which specifies the endpoint URL.

The `proc` block has one required parameter: `file_path`, 
which specifies the location of the output files.
There is an optional Boolean parameter, `compress_output`, 
which controls the compression of the output files. 
There is also an optional `process_name` parameter, 
which is used as a base name for the output files.

## Run options

The `run` block specifies parameters associated the actual query sent to the API. 
When the `run` block is not defined or contains no parameter settings,
the default behavior is to run 10 minute queries when the stop time of the query
is 5 minutes behind the current (wall clock) time. 
The overall stop time is effectively set to infinity.

To set a different start or stop time several optional parameters can be specified. All date/times
use the YYYYMMDDhhmm format. 

* `start_time` - time at which to begin a continuous set of queries
* `start_time_offset_in_seconds` - defines the start time for the initial query as an offset from the current time
* `stop_time` - time at which to stop making queries. A query for a time interval that includes the stop time will NOT be made. The default value is effectively infinity.

`start_time` and `start_time_offset_in_seconds` must not both be set. 

There are two other optional parameters for controlling the queries.

* `query_length_in_minutes` - length of each query, in minutes; default is 10; can not be greater than 10 
* `sleep_time_in_seconds` - wait period between checks for a new query; default is 10

There are three optional parameters for specifying additional request parameters. 
Allowed values are documented at [the support site](http://support.gnip.com/apis/compliance_api/):  

* `gnip_product`
* `gnip_stream_type`
* `gnip_stream_name`

# Running the application

To run the application, simply do: 

`> python src/GnipComplianceApiConnector.py`

from the repository after having created an appropriate version of `gnip.cfg`. 
For long-term runnng:

`> nohup python src/GnipComplianceApiConnector.py &`
