#!/usr/bin/env bash
#
bosh upload-release https://bosh.io/d/github.com/cppforlife/turbulence-release

# vault write secret/turbulence-wdc1-prod-pros turbulence-api-ip

bosh -n -d turbulence deploy ./manifests/turbulence.yml \
  -v turbulence_api_ip=$TURBULENCE_API_IP \
  -v director_ip=$DIRECTOR_IP \
  --var-file director_ssl_ca=$DIRECTOR_SSL_CA \
  -v director_client=$DIRECTOR_CLIENT \
  -v director_client_secret=$DIRECTOR_CLIENT_SECRET \
  --vars-store ./creds.yml

# EOF
