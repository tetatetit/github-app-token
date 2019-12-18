#!/usr/bin/env python

from sys import stdin
from datetime import datetime
from datetime import timedelta
from jwt.contrib.algorithms.pycrypto import RSAAlgorithm
import sys
import jwt
import requests
import json

jwt.register_algorithm('RS256', RSAAlgorithm(RSAAlgorithm.SHA256))
token = jwt.encode({
  # issued at time
  'iat': datetime.utcnow(),
  # JWT expiration time (10 minute maximum)
  'exp': datetime.utcnow() + timedelta(minutes=10),
  # GitHub App's identifier
  'iss': sys.argv[1]
}, stdin.read(), algorithm='RS256')

hdrs = {
    'Authorization': 'Bearer ' + token,
    'Accept': 'application/vnd.github.machine-man-preview+json'
}
endpoint = 'https://api.github.com/app/installations'

for _ in range(5):
    try:
        r = json.loads(
                requests.get(
                    endpoint,
                    headers=hdrs).content)
        r = json.loads(
                requests.post(
                    endpoint + '/' + str(r[0]['id']) + '/access_tokens',
                    headers=hdrs).content)
        break
    except:
        continue
print(r['token'])
