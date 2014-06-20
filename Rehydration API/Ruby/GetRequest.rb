require "net/https"     #HTTP gem.
require "uri"

# This uses the standard net/https gem.
# prints data to stdout.

url = "https://rehydration.gnip.com:443/accounts/<ACCOUNT_NAME>/publishers/twitter/rehydration/activities.json"
user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

tweetIds = '477926086391521280,479442146567544832'

uri = URI.parse(url)
uri.query = "ids=#{tweetIds}"

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

