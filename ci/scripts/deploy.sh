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
TURBULENCE_API_IP=$(vault read --field=turbulence-api-ip $VAULT_HASH_PROPS)

# Deploy
bosh -n -d turbulence deploy $project_dir/manifests/turbulence.yml \
  -v turbulence_api_ip=$TURBULENCE_API_IP \
  -v director_ip=$BOSH_URL \
  --var-file director_ssl_ca=$DIRECTOR_CA_CERT \
  -v director_client=$BOSH_CLIENT \
  -v director_client_secret=$BOSH_CLIENT_SECRET \
  --vars-store ./creds.yml

# Store values from creds.yml to vault
JSON=`ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' < creds.yml`

API_CA=`echo $JSON | jq -r '.turbulence_api_ca.ca'`
API_CERTIFICATE=`echo $JSON | jq -r '.turbulence_api_ca.certificate' `
API_CERT_CERTIFICATE=`echo $JSON | jq -r '.turbulence_api_cert.certificate' `
API_CERT_CA=`echo $JSON | jq -r  '.turbulence_api_cert.ca' `
TURBULENCE_API_PASSWORD=`echo $JSON | jq -r '.turbulence_api_password'`
set -x
vault write secret/turbulence-$FOUNDATION_NAME-pros turbulence-ca="$API_CA" \
                            turbulence-api-ip="$TURBULENCE_API_IP" \
                            turbulence-certificate="$API_CERTIFICATE" \
                            turbulence-api-password=$TURBULENCE_API_PASSWORD

# EOF
