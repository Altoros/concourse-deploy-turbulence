#!/usr/bin/env bash
#
#
set -e


project_dir=$(readlink -f "$(dirname $0)/../..")
source $project_dir/common/utils/load-bosh-env.sh 

export VAULT_HASH_PROPS=secret/turbulence-$FOUNDATION_NAME-pros

set -x

#TURBULENCE_BOSH_JOBS=$(vault read --field=turbulence-bosh-jobs --format=json $VAULT_HASH_PROPS )
TURBULENCE_API_PASSWORD=$(vault read --format=json --field=turbulence-api-password $VAULT_HASH_PROPS )
TURBULENCE_API_IP=$(vault read --format=json --field=turbulence-api-ip $VAULT_HASH_PROPS )
TURBULENCE_API_CERTIFICATE=$(vault read --format=json --field=turbulence-certificate $VAULT_HASH_PROPS )

echo $TURBULENCE_BOSH_JOBS
echo $TURBULENCE_API_IP
echo "$TURBULENCE_API_CERTIFICATE" > api-cert.pem

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
for BOSH_JOB in $TURBULENCE_BOSH_JOBS;
do
    echo $BOSH_JOB;
    #echo $body | curl -vvv -k -X POST https://turbulence:${TURBULENCE_API_PASSWORD}@$TURBULENCE_API_IP:8080/api/v1/incidents -H 'Accept: application/json' -d @-
done 

# EOF
