#!/usr/bin/env bash
#
### Load env

project_dir=$(readlink -f "$(dirname $0)/../..")
source $project_dir/common/utils/load-bosh-env.sh 

bosh upload-release https://bosh.io/d/github.com/cppforlife/turbulence-release

# vault write secret/turbulence-wdc1-prod-pros turbulence-api-ip

bosh -n -d turbulence deploy ./manifests/turbulence.yml \
  -v turbulence_api_ip=$(vault read --field=broker-ip $VAULT_HASH_PROPS  )$\
  -v director_ip=$BOSH_DIRECTOR_IP \
  --var-file director_ssl_ca=$BOSH_DIRECTOR_SSL_CA \
  -v director_client=$BOSH_DIRECTOR_CLIENT \
  -v director_client_secret=$BOSH_DIRECTOR_CLIENT_SECRET \


#  --vars-store ./creds.yml
# EOF
