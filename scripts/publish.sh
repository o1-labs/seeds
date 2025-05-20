#!/usr/bin/env bash

set -ex

GCS_BUCKET_NAME="${1}"

# Sync files to Google Cloud Storage
# -m for parallel uploads
# -r for recursive 
# -d to delete files in the destination that aren't in the source
gsutil -m rsync -r -d networks/ "gs://${GCS_BUCKET_NAME}/networks/"

# Set proper MIME types for text files for better browser handling
gsutil -m setmeta -h "Content-Type:text/plain" "gs://${GCS_BUCKET_NAME}/networks/*.txt"

echo "Successfully published network lists to Google Cloud Storage bucket: ${GCS_BUCKET_NAME}"
