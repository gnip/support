# !/usr/bin/env python

import urllib2
import base64
import json


def post():

    url = 'ENTER_HISTORICAL_JOB_URL'
    username = 'ENTER_USERNAME'
    password = 'ENTER_PASSWORD'

    # Switch to 'reject' to reject the job.
    choice = 'accept'

    payload = {
        "status": choice
        }

    base64string = base64.encodestring("{0}:{1}".format(username, password))
    req = urllib2.Request(url=url, data=json.dumps(payload))
    req.add_header('Content-type', 'application/json')
    req.add_header("Authorization", "Basic {}".format(base64string.strip()))
    req.get_method = lambda: 'PUT'

    try:
        response = urllib2.urlopen(req)
        print(response.read())
    except urllib2.HTTPError as e:
        print(e)

    if __name__ == "__main__":
        post()
