#!/usr/bin/env python
import urllib2
import base64


class RequestWithMethod(urllib2.Request):
    def __init__(self, url, method, headers={}):
        self._method = method
        urllib2.Request.__init__(self, url, headers)

    def get_method(self):
        if self._method:
            return self._method
        else:
            return urllib2.Request.get_method(self)

if __name__ == "__main__":
    url = 'ENTER_HISTORICAL_JOB_URL'
    username = 'ENTER_USERNAME'
    password = 'ENTER_PASSWORD'

    base64string = base64.encodestring("{0}:{1}".format(username, password))

    req = RequestWithMethod(url, 'GET')
    req.add_header('Content-type', 'application/json')
    req.add_header("Authorization", "Basic {}".format(base64string.strip()))

    try:
        response = urllib2.urlopen(req)
        print(response.read())
    except urllib2.HTTPError as e:
        print(e)
