require 'rubygems'
require 'curb'

# This uses the 'curb' libcurl wrapper for ruby, found at https://github.com/taf2/curb/  
# prints data to stdout.

url = "ENTER_API_URL_HERE"
user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

tweetId = "403245346194616320"

queryString = "{\"ids\":[\"" + tweetId + "\"]}"

Curl::Easy.http_post(url) do |c|
  c.http_auth_types = :basic
  c.username = user
  c.password = pass
  c.post_body = queryString
  c.verbose = true

  c.on_body do |data|
    puts data
    data.size # required by curl's api.
  end
end
