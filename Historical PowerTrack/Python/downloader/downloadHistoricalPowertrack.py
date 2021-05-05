#!/usr/bin/env python3
# By Brian Ballsun-Stanton, Macquarie Uni
# MIT License

# Designed to replace the PTDownloader GNIP package https://github.com/gnip/support


import json
from pprint import pprint
import tqdm
import os
import re
import requests

DIRECTORY="downloads"

with open("input/results.json") as jsonfile:
	to_download = json.load(jsonfile)

tqdm_wrapper = tqdm.tqdm(to_download['urlList'])
for line in tqdm_wrapper:
	url_split = re.split(r"/|\?", line)
	filename = f"{DIRECTORY}/{'_'.join(url_split[12:-1])}"
	try:
		with open(filename) as to_write_file:
			tqdm_wrapper.write(f"{filename} already exists, skipping...")
			pass
	except IOError:
		with open(filename, "wb") as to_write_file:
			r = requests.get(line)
			to_write_file.write(r.content)
