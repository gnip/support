require "net/https"     #HTTP gem.
require "uri"

# This uses the standard 'net/http' gem.
# prints data to stdout.

url = "ENTER_API_URL_HERE"
user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

rule = "(snow OR rain) profile_region:co"

queryString = "{\"query\":\"" + rule + "\",\"publisher\":\"twitter\",\"maxResults\":\"100\"}"

uri = URI(url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.path)
request.body = queryString
request.basic_auth(user, pass)

begin
    response = http.request(request)
rescue
    sleep 5
    response = http.request(request) #try again
end

puts response.body
