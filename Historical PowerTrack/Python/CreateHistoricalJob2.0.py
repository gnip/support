#!/usr/bin/env python
import urllib2
import base64
import json


def create_job():

    username = 'ENTER_USERNAME'
    password = 'ENTER_PASSWORD'
    account = 'ENTER_ACCOUNT_NAME'

    url = 'https://gnip-api.gnip.com/historical/powertrack/accounts/{}/publishers/twitter/jobs.json'.format(account)
    publisher = "Twitter"
    stream_type = "track_v2"
    data_format = "activity-streams"
    job_title = "test-job-python1"

    # This time is inclusive
    # meaning the minute specified will be included in the data returned
    from_date = "201301010000"

    # This time is exclusive
    # meaning the data returned will not contain the minute specified,
    # but will contain the minute immediately preceding it
    to_date = "201301010601"
    rules = [
        {"value": "rule 1",
         "tag": "ruleTag "},
        {"value": "rule 2",
         "tag": "ruleTag"}
        ]

    job = {
        "publisher": publisher,
        "streamType": stream_type,
        "dataFormat": data_format,
        "fromDate": from_date,
        "toDate": to_date,
        "title": job_title,
        "rules": rules
        }

    base64string = base64.encodestring("{0}:{1}".format(username, password))

    req = urllib2.Request(url=url, data=json.dumps(job))
    req.add_header("Content-type", "application/json")
    req.add_header("Authorization", "Basic {}".format(base64string.strip()))

    try:
        response = urllib2.urlopen(req)
        print(response.read())
    except urllib2.HTTPError as e:
        print(str(e))

if __name__ == "__main__":
        create_job()
