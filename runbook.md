# Runbook — StartTech Operations

## Useful Commands

### Check backend health
```bash
curl http://starttech-prod-alb-1625860634.eu-west-1.elb.amazonaws.com/health
```

### View live backend logs
```bash
aws logs tail /starttech/prod/backend --follow --region eu-west-1
```

### View errors only
```bash
aws logs filter-log-events \
  --log-group-name /starttech/prod/backend \
  --filter-pattern "ERROR" \
  --region eu-west-1
```

### Scale ASG manually
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name starttech-prod-backend-asg \
  --desired-capacity 4 \
  --region eu-west-1
```

### Deploy frontend manually
```bash
export S3_BUCKET_NAME=starttech-frontend-malik-2026
export CLOUDFRONT_DISTRIBUTION_ID=E3OVRST3PTBYFR
bash scripts/deploy-frontend.sh
```

---

## Troubleshooting

### ALB shows unhealthy targets

1. Connect to EC2 via SSM Session Manager:
```bash
aws ssm start-session --target <instance-id> --region eu-west-1
```

2. Check container is running:
```bash
docker ps
docker logs starttech-backend --tail 50
```

3. Test health check locally:
```bash
curl localhost:8080/health
```

4. Check userdata logs:
```bash
cat /var/log/userdata.log
```

**Common causes:**
- Wrong ECR image URI in Launch Template
- MongoDB URI SSM parameter missing or wrong
- Container crash loop

### Frontend showing stale content
```bash
aws cloudfront create-invalidation \
  --distribution-id E3OVRST3PTBYFR \
  --paths "/*" \
  --region eu-west-1
```

### Backend deploy stuck
Check refresh status:
```bash
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name starttech-prod-backend-asg \
  --region eu-west-1
```

Cancel and rollback:
```bash
bash scripts/rollback.sh starttech-prod-backend-asg
```

---

## CloudWatch Alarms

| Alarm | Threshold | Meaning |
|-------|-----------|---------|
| `starttech-prod-asg-cpu-high` | CPU > 80% for 4 min | Instances under heavy load |
| `starttech-prod-unhealthy-hosts` | Any unhealthy host | Backend instances failing health checks |
| `starttech-prod-alb-5xx` | >10 errors in 60s | Backend returning server errors |

---

## Infrastructure Values

| Resource | Value |
|----------|-------|
| ALB DNS | `starttech-prod-alb-1625860634.eu-west-1.elb.amazonaws.com` |
| CloudFront Domain | `dt0asqnm05hbg.cloudfront.net` |
| CloudFront ID | `E3OVRST3PTBYFR` |
| S3 Bucket | `starttech-frontend-malik-2026` |
| ASG Name | `starttech-prod-backend-asg` |
| ECR Repo | `160885273554.dkr.ecr.eu-west-1.amazonaws.com/starttech-backend` |
| Backend Log Group | `/starttech/prod/backend` |