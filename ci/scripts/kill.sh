#!/usr/bin/env bash
#
#
set -xe


project_dir=$(readlink -f "$(dirname $0)/../..")
source $project_dir/common/utils/load-bosh-env.sh 

export VAULT_HASH_PROPS=secret/turbulence-$FOUNDATION_NAME-pros


TURBULENCE_BOSH_JOBS=$(vault read --format=json turbulence-bosh-jobs $VAULT_HASH_PROPS | jq .turbulence-bosh-jobs)
TURBULENCE_API_PASSWORD=$(vault read --format=json turbulence-ca $VAULT_HASH_PROPS | jq .turbulence-ca)
TURBULENCE_API_IP=$(vault read --format=json turbulence-api-ip $VAULT_HASH_PROPS | jq .turbulence-api-ip )
echo $TURBULENCE_BOSH_JOBS
echo $TURBULENCE_API_IP
exit 0;
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
