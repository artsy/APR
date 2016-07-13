#!/bin/bash

set -e

# Generate a release for the given environment
export MIX_ENV=$APR_RELEASE_ENVIRONMENT

# Set compile-time environment vars - secrets here should be injected from CircleCI configuration
export BASIC_AUTH_USER=$APR_BASIC_AUTH_USER
export BASIC_AUTH_PASSWORD=$APR_BASIC_AUTH_PASSWORD

# Compile application code
mix compile
node node_modules/brunch/bin/brunch build --production
mix phoenix.digest

# Build release
mix release

# Upload release to S3
RELEASE_BUNDLE=apr-$APR_RELEASE_ENVIRONMENT-$CIRCLE_SHA1.tgz
tar cvzf $RELEASE_BUNDLE rel
aws s3 cp $RELEASE_BUNDLE s3://artsy-deploy/apr/$RELEASE_BUNDLE
aws s3 cp $RELEASE_BUNDLE s3://artsy-deploy/apr/latest

# clean up
rm -rf _build/ && rm -rf rel/
