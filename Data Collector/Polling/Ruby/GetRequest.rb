require 'rubygems'
require 'curb'

# This uses the 'curb' libcurl wrapper for ruby, found at https://github.com/taf2/curb/  
# prints data to stdout.

# Ensure that your stream format matches the data format you intend to use (e.g. '.xml' or '.json')
			
# Expected Enterprise Data Collector URL formats:
# 	JSON:	https://<host>.gnip.com/data_collectors/<data_collector_id>/activities.json
# 	XML:	https://<host>.gnip.com/data_collectors/<data_collector_id>/activities.xml

url = "ENTER_API_URL_HERE"

user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

Curl::Easy.http_get url do |c|
  c.http_auth_types = :basic
  c.username = user
  c.password = pass
  c.verbose = true # Modify to false to limit output to only JSON rule payload 

  c.on_body do |data|
    puts data
    data.size # required by curl's api.
  end
end
