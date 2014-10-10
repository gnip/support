#!/usr/bin/env python

import urllib2
import base64
import json
import sys

def post():

	UN = 'ENTER_USERNAME'
	PWD = 'ENTER_PASSWORD'
	account = 'ENTER_GNIP_CONSOLE_ACCOUNT_NAME'

	url = 'https://historical.gnip.com/accounts/' + account + '/jobs.json'
	publisher = "twitter"
	streamType = "track"
	dataFormat = "activity-streams"
	fromDate = "201301010000" # This time is inclusive -- meaning the minute specified will be included in the data returned
	toDate = "201301010001" # This time is exclusive -- meaning the data returned will not contain the minute specified, but will contain the minute immediately preceding it
	jobTitle = "my historical job python"
	rules = '[{"value":"rule 1","tag":"ruleTag"},{"value":"rule 2","tag":"ruleTag"}]'

	jobString = '{"publisher":"' + publisher + '","streamType":"' + streamType + '","dataFormat":"' + dataFormat + '","fromDate":"' + fromDate + '","toDate":"' + toDate + '","title":"' + jobTitle + '","rules":' + rules + '}'

	base64string = base64.encodestring('%s:%s' % (UN, PWD)).replace('\n', '')
	req = urllib2.Request(url=url, data=jobString)
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
