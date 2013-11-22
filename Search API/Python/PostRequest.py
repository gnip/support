#!/usr/bin/env python

import urllib2
import base64
import json
import xml
import sys

def post():

	url = 'ENTER_API_URL_HERE'
	UN = 'ENTER_USERNAME_HERE'
	PWD = 'ENTER_PASSWORD_HERE'

	rule = 'gnip'

	query = '{"query":"' + rule + '","publisher":"twitter"}'


	base64string = base64.encodestring('%s:%s' % (UN, PWD)).replace('\n', '')
	req = urllib2.Request(url=url, data=query)
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
