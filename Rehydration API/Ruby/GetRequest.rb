require "net/https"     #HTTP gem.
require "uri"

# This uses the standard net/https gem.
# prints data to stdout.

url = "ENTER_API_URL_HERE"
user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

tweetId = '477926086391521280,479442146567544832'

uri = URI.parse(url)
uri.query = "ids=" + tweetId

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Get.new(uri.request_uri)
request.basic_auth(user, pass)

begin
    response = http.request(request)
rescue
    sleep 5
    response = http.request(request) #try again
end

#Print out response.
puts response.body

