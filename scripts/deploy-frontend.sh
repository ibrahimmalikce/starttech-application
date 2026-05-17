#!/usr/bin/env bash
set -euo pipefail

S3_BUCKET="${S3_BUCKET_NAME:?Set S3_BUCKET_NAME env var}"
CF_DIST_ID="${CLOUDFRONT_DISTRIBUTION_ID:?Set CLOUDFRONT_DISTRIBUTION_ID env var}"

echo "Building React app..."
cd frontend
npm ci
REACT_APP_API_URL=/api/v1 npm run build
cd ..

echo "Uploading to S3..."
aws s3 sync frontend/build/ "s3://$S3_BUCKET/" \
  --delete \
  --exclude "index.html" \
  --cache-control "public,max-age=31536000,immutable"

aws s3 cp frontend/build/index.html "s3://$S3_BUCKET/index.html" \
  --cache-control "no-cache,no-store,must-revalidate"

echo "Invalidating CloudFront..."
aws cloudfront create-invalidation \
  --distribution-id "$CF_DIST_ID" \
  --paths "/*"

echo "✅ Frontend deployed!"