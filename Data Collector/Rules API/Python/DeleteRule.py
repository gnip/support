#!/usr/bin/env python

import urllib2
import base64
import json
import xml
import sys

class RequestWithMethod(urllib2.Request):
    def __init__(self, url, method, data, headers={}):
        self._method = method
        urllib2.Request.__init__(self, url, data, headers)

    def get_method(self):
        if self._method:
            return self._method
        else:
            return urllib2.Request.get_method(self) 

if __name__ == "__main__":

#	Ensure that your stream format matches the rule format you intend to use (e.g. '.xml' or '.json')
#	See below to edit the rule format used when adding and deleting rules (xml or json)
			
#	Expected Enterprise Data Collector URL formats:
#		JSON:	https://<host>.gnip.com/data_collectors/<data_collector_id>/rules.json
#		XML:	https://<host>.gnip.com/data_collectors/<data_collector_id>/rules.xml
    
	url = 'ENTER_RULES_API_URL_HERE'

	UN = 'ENTER_USERNAME_HERE'
	PWD = 'ENTER_PASSWORD_HERE'

	rule = 'testRule'

#	Edit below to use the rule format that matches the Rules API URL you entered above

#	Use this line for JSON formatted rules
#	values = '{"rules":[{"value":"' + rule + '"}]}'

#	Use this line for XML formatted rules
	values = '<rules><rule><value>' + rule + '</value></rule></rules>'

	base64string = base64.encodestring('%s:%s' % (UN, PWD)).replace('\n', '')
	req = RequestWithMethod(url, 'DELETE', data=values)

#	Use this line for JSON formatted rules
#	req.add_header('Content-type', 'application/json')

#	Use this line for XML formatted rules
	req.add_header('Content-type', 'application/xml')

	req.add_header("Authorization", "Basic %s" % base64string)

	try:
		response = urllib2.urlopen(req)
	except urllib2.HTTPError as e:
            	print e.read()

	the_page = response.read()
