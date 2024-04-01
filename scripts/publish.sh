#!/usr/bin/env bash

set -ex

MF_SEED_LISTS_BUCKET_NAME="${1}"

aws s3 sync --delete networks/ "s3://${MF_SEED_LISTS_BUCKET_NAME}/networks/"
