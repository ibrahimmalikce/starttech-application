# Architecture

## System Diagram
Internet → CloudFront → S3 (React frontend)
↘
ALB (public subnets)
↓
ASG — EC2 instances (private subnets)
↓              ↓
ElastiCache     MongoDB Atlas
(Redis)

## Components

### Frontend — React + S3 + CloudFront
- React app built and synced to S3 on every push to `frontend/**`
- CloudFront serves the app globally with HTTPS
- `/api/*` requests are proxied by CloudFront to the ALB
- `index.html` has no-cache headers so users always get the latest version
- Hashed JS/CSS assets have 1-year immutable cache headers

### Backend — Go + EC2 + ALB
- Go API built with chi router and zap structured logger
- Runs as a Docker container on EC2 instances in private subnets
- ALB health checks hit `/health` every 30 seconds
- ASG scales between 2 and 4 instances based on CPU utilization (target: 70%)
- Rolling deploys via ASG instance refresh (50% minimum healthy)

### Database — MongoDB Atlas
- Managed MongoDB hosted on AWS eu-west-1
- Connection string stored as SecureString in SSM Parameter Store
- EC2 instances pull the URI at boot via IAM role

### Cache — ElastiCache Redis
- Single-node Redis 7.1 on cache.t3.micro
- Only accessible from EC2 security group on port 6379
- Used for session storage and API response caching

### Infrastructure — Terraform
- Modular structure: networking, compute, storage, monitoring
- Remote state stored in S3 with DynamoDB locking
- All resources tagged with Project, Environment, ManagedBy

## Security

- EC2 instances in private subnets — no direct internet access
- ALB security group only accepts HTTP on port 80 from internet
- EC2 security group only accepts port 8080 from ALB security group
- Redis security group only accepts port 6379 from EC2 security group
- S3 bucket blocks all public access — only CloudFront OAC can read it
- IAM role uses least privilege — EC2 can only read SSM params under `/starttech/*`
- Trivy scans every Docker image before push to ECR
- npm audit runs on every frontend build

## CI/CD Flow
Push to main
↓
GitHub Actions
↓
frontend/** → Build → Test → S3 Sync → CloudFront Invalidation
backend/**  → Test → Lint → Docker Build → Trivy Scan → ECR Push → ASG Refresh → Smoke Test
terraform/** → Plan → Apply

