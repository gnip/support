require 'net/https'
require 'uri'

# This uses the standard net/https gem.
# prints data to stdout.

url = "ENTER_API_URL_HERE"
user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

rule = 'gnip country_code:us'

uri = URI.parse(url)

uri.query =  "publisher=twitter&query=#{URI.encode(rule)}&maxReults=500"

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

puts response.body


