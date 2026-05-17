#!/usr/bin/env bash
set -euo pipefail

ASG_NAME="${1:?Usage: rollback.sh <asg-name>}"
AWS_REGION="${AWS_REGION:-eu-west-1}"

echo "⚠️  Rolling back ASG: $ASG_NAME"

# Cancel any in-progress refresh
REFRESH_ID=$(aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name "$ASG_NAME" \
  --region "$AWS_REGION" \
  --query 'InstanceRefreshes[?Status==`InProgress`].InstanceRefreshId' \
  --output text)

if [[ -n "$REFRESH_ID" && "$REFRESH_ID" != "None" ]]; then
  echo "Cancelling in-progress refresh: $REFRESH_ID"
  aws autoscaling cancel-instance-refresh \
    --auto-scaling-group-name "$ASG_NAME" \
    --region "$AWS_REGION"
  sleep 10
fi

# Get Launch Template info
LT_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --region "$AWS_REGION" \
  --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
  --output text)

CURRENT_VERSION=$(aws ec2 describe-launch-templates \
  --launch-template-ids "$LT_ID" \
  --region "$AWS_REGION" \
  --query 'LaunchTemplates[0].DefaultVersionNumber' \
  --output text)

PREV_VERSION=$((CURRENT_VERSION - 1))

if [[ $PREV_VERSION -lt 1 ]]; then
  echo "❌ No previous version to roll back to"
  exit 1
fi

echo "Setting LT version to $PREV_VERSION (was $CURRENT_VERSION)"
aws ec2 modify-launch-template \
  --launch-template-id "$LT_ID" \
  --default-version "$PREV_VERSION" \
  --region "$AWS_REGION"

echo "Starting rollback instance refresh..."
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$ASG_NAME" \
  --region "$AWS_REGION" \
  --preferences '{"MinHealthyPercentage":50,"InstanceWarmup":60}'

echo "✅ Rollback initiated."