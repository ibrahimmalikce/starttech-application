# StartTech Application

Full-stack application with React frontend and Go backend, deployed on AWS with full CI/CD automation.

## Repositories

- **starttech-infra** — Terraform infrastructure
- **starttech-application** — Application code and CI/CD pipelines

## Architecture

- **Frontend** — React app served from S3 via CloudFront CDN
- **Backend** — Go API running on EC2 instances behind an ALB
- **Database** — MongoDB Atlas
- **Cache** — ElastiCache Redis
- **Infrastructure** — All managed with Terraform

## CI/CD Pipelines

### Frontend Pipeline
Triggered by changes to `frontend/**` on main branch.
- Installs dependencies
- Runs security audit
- Runs tests
- Builds production bundle
- Syncs to S3
- Invalidates CloudFront cache

### Backend Pipeline
Triggered by changes to `backend/**` on main branch.
- Runs `go vet` and tests
- Runs golangci-lint
- Builds Docker image
- Scans for vulnerabilities with Trivy
- Pushes to ECR
- Triggers ASG rolling instance refresh
- Runs smoke test against ALB

## Local Development

### Backend
```bash
cd backend
go mod download
PORT=8080 MONGODB_URI=mongodb://localhost:27017/starttech REDIS_ADDR=localhost:6379 go run ./cmd/api
```

### Frontend
```bash
cd frontend
npm install
npm start
```

## GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM credentials |
| `AWS_SECRET_ACCESS_KEY` | IAM credentials |
| `S3_BUCKET_NAME` | Frontend S3 bucket |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID |
| `ASG_NAME` | Auto Scaling Group name |
| `ALB_DNS_NAME` | ALB DNS for smoke tests |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | ALB health check |
| GET | `/api/v1/status` | App status |