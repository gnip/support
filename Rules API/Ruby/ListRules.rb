require 'rubygems'
require 'curb'

# This uses the 'curb' libcurl wrapper for ruby, found at https://github.com/taf2/curb/  

# Expected Premium Stream URL Format:
# https://api.gnip.com:443/accounts/<account>/publishers/<publisher>/streams/<stream>/<label>/rules.json

url = "ENTER_RULES_API_URL_HERE"
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
