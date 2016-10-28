#!/bin/sh

body='{
"request": {
  "branch": "master"
}}'

curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Travis-API-Version: 3" \
     -H "Authorization: token $TRAVIS_TOKEN" \
     -d "$body" \
     https://api.travis-ci.org/repo/atgreen%2Fmoxiedev-builder/requests
