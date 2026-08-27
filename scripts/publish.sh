#!/usr/bin/env bash

set -ex

GCS_BUCKET_NAME="${1}"

# Sync files to Google Cloud Storage
# --no-ignore-symlinks to follow symlinks instead of skipping them
# --recursive for recursive
# --delete-unmatched-destination-objects to delete files in the destination that aren't in the source
gcloud storage rsync --no-ignore-symlinks --recursive --delete-unmatched-destination-objects networks/ "gs://${GCS_BUCKET_NAME}/networks/"

# Set proper MIME types for text files for better browser handling
gcloud storage objects update --content-type=text/plain "gs://${GCS_BUCKET_NAME}/networks/*.txt"

echo "Successfully published network lists to Google Cloud Storage bucket: ${GCS_BUCKET_NAME}"
