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

# Deploy
bosh -n -d turbulence deploy $project_dir/manifests/turbulence.yml \
  -v turbulence_api_ip=$(vault read --field=turbulence-api-ip $VAULT_HASH_PROPS) \
  -v director_ip=$BOSH_URL \
  --var-file director_ssl_ca=$DIRECTOR_CA_CERT \
  -v director_client=$BOSH_CLIENT \
  -v director_client_secret=$BOSH_CLIENT_SECRET \
  --vars-store ./creds.yml
# Store values from creds.yml to vault

JSON=`ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' < creds.yml`

API_CA=`echo $JSON | jq -r '.turbulence_api_ca.ca'`
API_CERTIFICATE=`echo $JSON | jq -r '.turbulence_api_ca.certificate' `
API_PRIVATE_KEY=`| jq -r '.turbulence_api_ca.private_key' `
API_CERT_CERTIFICATE=`echo $JSON | jq -r '.turbulence_api_cert.certificate' `
API_CERT_PRIVATE_KEY=`echo $JSON | jq -r '.turbulence_api_cert.private_key' `
API_CERT_CA=`echo $JSON | jq -r  '.turbulence_api_cert.ca' `
TURBULENCE_API_PASSWORD=`echo $JSON | jq -r '.turbulence_api_ca.private_key' `

vault write turbulence-$FOUNDATION_NAME-pros/turbulence-api-ca: \
                            ca=$API_CA \
                            certificate=$API_CERTIFICATE \
                            private_key=$API_PRIVATE_KEY 

vault write turbulence-$FOUNDATION_NAME-pros/turbulence-api-cert: \
                            ca=$API_CERT_CA \
                            certificate=$API_CERT_CERTIFICATE \
                            private_key=$API_CERT_PRIVATE_KEY 

vault write turbulence-$FOUNDATION_NAME-pros/turbulence-api-cert: \
                           turbulence_api_password: $TURBULENCE_API_PASSWORD

# EOF
