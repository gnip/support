#!/usr/bin/env python

import urllib2
import base64
import json
import xml
import sys

def post():

#	Expected Premium Stream URL Format:
#	https://api.gnip.com:443/accounts/<account>/publishers/<publisher>/streams/<stream>/<label>/rules.json
    
	url = 'ENTER_RULES_API_URL_HERE'
	UN = 'ENTER_USERNAME_HERE'
	PWD = 'ENTER_PASSWORD_HERE'

	rule = 'testRule'
	tag = 'testTag'

	values = '{"rules": [{"value":"' + rule + '","tag":"' + tag + '"}]}'

	base64string = base64.encodestring('%s:%s' % (UN, PWD)).replace('\n', '')
	req = urllib2.Request(url=url, data=values)
	req.add_header('Content-type', 'application/json')
	req.add_header("Authorization", "Basic %s" % base64string)  
	
	try:
		response = urllib2.urlopen(req)
	except urllib2.HTTPError as e:
		print e.read()
		
	the_page = response.read()
	print the_page

if __name__ == "__main__":
        post()
