#!/usr/bin/env bash
#
#
set -xe

body='
{
  "Tasks": [{
    "Type": "kill"
  }],
  "Selector": {
    "Deployment": {
      "Name": "cf-scdc1-prod"
    },
    "Group": {
      "Name": "diego_cell-partition"
    },
    "ID": {
      "Limit": "10%-30%"
    }
  }
}
'

echo $body | curl -vvv -k -X POST https://turbulence:${TURBULENCE_API_PASSWORD}@$TURBULENCE_API_IP:8080/api/v1/incidents -H 'Accept: application/json' -d @-

echo "" 

# EOF
