#!/usr/bin/env bash
#
### Load env
project_dir=$(readlink -f "$(dirname $0)/../..")
source $project_dir/common/utils/load-bosh-env.sh 

bosh upload-release https://bosh.io/d/github.com/cppforlife/turbulence-release
export VAULT_HASH_PROPS=secret/turbulence-$FOUNDATION_NAME-pros
export DIRECTOR_CA_CERT=./directorCA.pem
# vault write secret/turbulence-wdc1-prod-pros turbulence-api-ip


echo "$BOSH_CA_CERT" > $DIRECTOR_CA_CERT
set -x

bosh -n -d turbulence deploy $project_dir/manifests/turbulence.yml \
  -v turbulence_api_ip=$(vault read --field=turbulence-api-ip $VAULT_HASH_PROPS) \
  -v director_ip=$BOSH_URL \
  --var-file director_ssl_ca=$DIRECTOR_CA_CERT \
  -v director_client=$BOSH_CLIENT \
  -v director_client_secret=$BOSH_CLIENT_SECRET \
  --vars-store ./creds.yml

# EOF
