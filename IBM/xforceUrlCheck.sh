#!/bin/bash


CHECK=$1
KEY=your_api_key
PASS=your_api_password
BASE=https://exchange.xforce.ibmcloud.com/api/url

AUTH=$( echo -n "$KEY:$PASS"| base64 -w 0)


curl -sS -X GET --header 'Accept: application/json' --header 'Authorization: Basic '"$AUTH"''  $BASE/$CHECK | jq .

