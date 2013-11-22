require 'rubygems'
require 'curb'

# This uses the 'curb' libcurl wrapper for ruby, found at https://github.com/taf2/curb/  
# prints data to stdout.

# Note: this snippet DOES NOT handle breaking up the chunks of data into separate lines.
# You should take this into account and provide additional functionality to do so.

user = "YOUR_USERNAME_HERE"
pass = "YOUR_PASSWORD_HERE"
url = "YOUR_STREAM_URL_HERE"

Curl::Easy.http_get url do |c|
  c.http_auth_types = :basic
  c.username = user
  c.password = pass
  c.verbose = true
  c.on_body do |data|
    puts data
    data.size # required by curl's api.
  end
end
