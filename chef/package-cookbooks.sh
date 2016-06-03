#! /bin/bash

if [ -z "$1" ]
  then
    echo "You must supply the environment to upload the cookbooks -- i.e. staging/production"
    exit 1
fi

berks update
berks package apr-cookbooks-$1.tgz
s3cmd put apr-cookbooks-$1.tgz s3://artsy-cookbooks/
rm apr-cookbooks-$1.tgz
