#!/usr/bin/env python

import urllib2
import base64
import json
import sys

def post():

	url = 'ENTER_HISTORICAL_JOB_URL'
	UN = 'ENTER_USERNAME'
	PWD = 'ENTER_PASSWORD'

	choice = 'accept' # Switch to 'reject' to reject the job.

	payload = '{"status":"' + choice + '"}'


	base64string = base64.encodestring('%s:%s' % (UN, PWD)).replace('\n', '')
	req = urllib2.Request(url=url, data=payload)
	req.add_header('Content-type', 'application/json')
	req.add_header("Authorization", "Basic %s" % base64string)
	req.get_method = lambda: 'PUT'
	
	try:
		response = urllib2.urlopen(req)
	except urllib2.HTTPError as e:
		print e.read()
	the_page = response.read()
	print the_page

if __name__ == "__main__":
        post()
