require "net/https"     #HTTP gem.
require "uri"

# This uses the standard 'net/http' gem.
# prints data to stdout.

# Rules API endpoint format:
#   https://api.gnip.com:443/accounts/<account>/publishers/<publisher>/streams/<stream>/<label>/rules.json

url = "ENTER_RULES_API_URL_HERE"
user = "ENTER_USERNAME_HERE"
pass = "ENTER_PASSWORD_HERE"

rule_value = "(gnip OR \\\"this exact phrase\\\") country_code:us"
rule_tag = "my_tag"

rules_json = "{\"rules\":[{\"value\":\"" + rule_value + "\",\"tag\":\"" + rule_tag + "\"}]}"

uri = URI(url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Delete.new(uri.path)
request.body = rules_json
request.basic_auth(user, pass)

begin
    response = http.request(request)
rescue
    sleep 5
    response = http.request(request) #try again
end

puts response
