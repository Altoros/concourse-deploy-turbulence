#!/usr/bin/env bash
set -ex

vault write secret/$PRODUCT_NAME-$FOUNDATION_NAME-props @deployment-props.json

./common/bin/update-pipeline

