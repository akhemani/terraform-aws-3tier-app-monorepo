## 🪜 Phase 3 — Application Delivery & Observability (Compute & Access Layer)

This phase adds the **application delivery and monitoring layer** on top of the secure data foundation built in Phase 2.  
It introduces **ECS Fargate, Application Load Balancer (ALB), CloudWatch Logs,** and **Terraform remote backend** for reliable state management.

### 🎯 Objective

To deploy a **containerized backend application** securely and reliably using:

* 🧱 ECS Fargate — serverless container orchestration (no EC2 management)
* 🌐 Application Load Balancer — distributes HTTPS traffic to ECS tasks
* 🪣 S3 + DynamoDB backend — stores and locks Terraform state remotely
* 📊 CloudWatch Logs — centralized log management for ECS containers
* 🔑 IAM Roles & Policies — granular access control for ECS tasks and execution

### 📁 Directory Structure
```
phase-3/
├── provider.tf           # Providers and region setup
├── vpc.tf                # VPC, subnets, gateways, routing
├── security-groups.tf    # Web, App, RDS, and ALB security groups
├── ec2.tf                # Web EC2 instance (for bastion/admin access)
├── ecs.tf                # ECS cluster, task definition, and service
├── alb.tf                # Application Load Balancer (HTTP→HTTPS)
├── rds.tf                # RDS PostgreSQL instance (encrypted)
├── kms.tf                # KMS encryption key and alias
├── secrets.tf            # Secrets Manager for DB credentials
├── iam.tf                # IAM role lookup and optional task role
├── cloudwatch.tf         # CloudWatch log group for ECS
├── backend.tf            # Remote backend (S3 + DynamoDB state lock)
├── variables.tf          # Input variables for parameters
├── terraform.tfvars      # Real values (image, cert, etc.)
├── outputs.tf            # ALB DNS, ECS service/cluster info
└── .gitignore            # Ignore Terraform state & sensitive files
```
### ⚙️ What Each File Does (What + Why)
| **File**                   | **What It Defines**                                    | **Why It Matters**                                         |
|----------------------------|--------------------------------------------------------|-----------------------------------------------------------|
| `provider.tf`               | Terraform & AWS provider setup.                        | Foundation for all resources.                              |
| `vpc.tf`                    | Networking (VPC, subnets, gateways, routes).           | Provides networking base for ECS and ALB.                  |
| `security-groups.tf`        | SGs for Web, ALB, App, and DB.                         | Enforces network isolation between layers.                 |
| `ec2.tf`                    | Optional bastion/web EC2 instance.                     | Used for admin SSH or frontend hosting.                    |
| `alb.tf`                    | Application Load Balancer, target group, and listeners (HTTP→HTTPS). | Provides secure and scalable external access.              |
| `ecs.tf`                    | ECS Cluster, Task Definition, and Service.             | Runs and scales containerized backend app.                 |
| `iam.tf`                    | Existing execution role lookup + task role creation.   | Grants ECS permissions to pull images and access AWS APIs. |
| `rds.tf`                    | PostgreSQL database definition (encrypted).            | Connects backend with secure persistence.                  |
| `kms.tf`                    | KMS CMK for encryption.                                | Encrypts secrets and RDS data.                             |
| `secrets.tf`                | Random password + Secrets Manager.                     | Stores credentials safely outside code.                    |
| `cloudwatch.tf`             | ECS log group with retention.                          | Enables centralized logging and debugging.                 |
| `backend.tf`                | Remote Terraform state in S3 + DynamoDB.               | Ensures collaboration and state consistency.               |
| `variables.tf / terraform.tfvars` | Configurable input variables.                         | Enables flexibility across environments.                   |
| `outputs.tf`                | DNS, cluster, and service identifiers.                 | Helps locate critical outputs post-deployment.             |


### 🧠 Why This Phase Is Important

Phase 3 enables **production-grade application delivery** with observability and resilience built-in.

* 🚀 ECS Fargate removes server management overhead.
* 🔄 ALB + HTTPS ensures secure, load-balanced access.
* 🔍 CloudWatch Logs centralizes logs for debugging and audits.
* 🧩 S3 + DynamoDB backend makes Terraform operations safe for teams.
* 🔒 IAM roles & policies enforce least-privilege access control.

### 🚀 How to Deploy

**Initialize Terraform**
```
terraform init
```

**Validate configuration**
```
terraform validate
```

**Preview the plan**
```
terraform plan
```

**Apply the infrastructure**
```
terraform apply
```

**Verify outputs**
```
terraform output
```
### ✅ Validation Checklist
| **Check**               | **AWS Console Path**                        | **Expected Result**                                        |
|-------------------------|---------------------------------------------|-----------------------------------------------------------|
| ALB DNS Name            | EC2 → Load Balancers                       | DNS name resolves publicly (`todo-app-alb-xxxx.elb.amazonaws.com`) |
| Listeners               | EC2 → Load Balancers → Listeners           | HTTP → Redirect (HTTPS 443) ✅                             |
| Target Group Health     | EC2 → Target Groups                        | All ECS tasks healthy ✅                                   |
| ECS Cluster             | ECS → Clusters                             | Service = Running ✅                                       |
| CloudWatch Logs         | CloudWatch → Log Groups                     | `/ecs/todo-app` contains app logs                          |
| Secrets Access          | Secrets Manager                            | Secret `todo-rds-password` encrypted ✅                    |
| KMS Key                 | KMS → Customer Managed Keys                | Alias `alias/todo-rds-kms` exists ✅                       |
| Terraform State         | S3 → Bucket `my-3-tier-aws-terraform-state-bucket` | `terraform.tfstate` present ✅                              |
| Lock Table              | DynamoDB → Tables `terraform-lock-table`    | Shows active lock entries ✅                               |

### 🧹 Cleanup

To destroy Phase 3 resources safely (leaving the S3 backend intact):
```
terraform destroy
```

⚠️ To remove the backend bucket or DynamoDB table, delete them manually in AWS Console (recommended only after full teardown).

### 🔐 Security Highlights
| **Component**           | **Security Measure**                             |
|-------------------------|--------------------------------------------------|
| ALB                     | HTTPS enabled with ACM certificate               |
| Network                 | ALB → App SG → RDS SG path only                 |
| ECS Tasks               | IAM roles restrict AWS API access               |
| Secrets                 | Stored in Secrets Manager (KMS encrypted)        |
| Terraform State         | Encrypted in S3 and locked via DynamoDB          |

### 🧭 Next Phase Preview
#### Phase 4 — Domain Integration & CI/CD Automation

* Route 53 DNS records (frontend + backend)
* GitHub Actions workflow for Terraform apply
* ACM certificate auto-validation via Terraform
* CI/CD pipeline triggered on push to main
* Optional monitoring alerts and dashboards
