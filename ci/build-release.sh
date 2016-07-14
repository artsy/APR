#!/bin/bash

set -e

export MIX_ENV=prod
cd $HOME/$CIRCLE_PROJECT_REPONAME

# Set compile-time environment vars - secrets here should be injected from CircleCI configuration
# Caveat - Circle does not inject encrypted env vars from PRs from forks!
export BASIC_AUTH_USER=$APR_BASIC_AUTH_USER
export BASIC_AUTH_PASSWORD=$APR_BASIC_AUTH_PASSWORD

# Compile application code
mix compile
node node_modules/brunch/bin/brunch build --production
mix phoenix.digest

# Build release
mix release

# Upload release to S3
RELEASE_BUNDLE=apr-$MIX_ENV-$CIRCLE_SHA1.tgz
tar cvzf $RELEASE_BUNDLE rel
aws s3 cp $RELEASE_BUNDLE s3://artsy-deploy/apr/$RELEASE_BUNDLE
aws s3 cp $RELEASE_BUNDLE s3://artsy-deploy/apr/latest.tgz
