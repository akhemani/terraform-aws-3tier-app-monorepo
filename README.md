# 🪜 Phase 2 — Database, Secrets & Encryption (Data Layer Security)

This phase adds a **secure data layer** to the 3-tier AWS architecture built with Terraform.  
It introduces **RDS (PostgreSQL)**, **AWS KMS** for encryption, and **Secrets Manager** for safely managing credentials.

---

## 🎯 Objective

To implement a **private, encrypted database layer** that:

- Runs inside **private subnets** (no public exposure)
- Uses a **randomly generated password**
- Stores credentials securely in **AWS Secrets Manager**
- Encrypts all data at rest using a **KMS Customer-Managed Key (CMK)**

---

## 📁 Directory Structure

```phase-2/
├── provider.tf # Terraform + provider configuration
├── variables.tf # All configurable variables
├── vpc.tf # VPC, subnets, gateways, routing
├── security-groups.tf # Web, App, and RDS security groups
├── ec2.tf # Web and App EC2 instances
├── kms.tf # KMS key and alias for encryption
├── secrets.tf # Random password + Secrets Manager
├── rds.tf # RDS database, subnet group, security setup
├── outputs.tf # Important outputs (IPs, ARNs, endpoints)
└── .gitignore # Ignore state & sensitive files
```


---

## ⚙️ What Each File Does (What + Why)

| File | What It Defines | Why It Matters |
|------|------------------|----------------|
| **provider.tf** | Declares Terraform, AWS, and Random providers. | Ensures Terraform knows which cloud and version to use. |
| **variables.tf** | Holds all user-configurable inputs (region, CIDRs, key, DB details). | Makes configuration reusable and environment-agnostic. |
| **vpc.tf** | Builds networking layer – VPC, subnets, gateways, routing. | Forms the base network where all resources reside. |
| **security-groups.tf** | Creates Web, App, and RDS security groups. | Defines firewall boundaries between each layer. |
| **ec2.tf** | Launches Web (public) and App (private) EC2 instances. | Simulates compute tiers for application logic. |
| **kms.tf** | Creates and manages a KMS key with alias and rotation. | Encrypts RDS and Secrets data for compliance. |
| **secrets.tf** | Generates a random password and stores it in Secrets Manager. | Removes plaintext credentials from code and state. |
| **rds.tf** | Deploys encrypted PostgreSQL RDS instance in private subnets. | Provides secure, durable data persistence. |
| **outputs.tf** | Exposes key outputs like RDS endpoint, secret ARN, KMS key ARN. | Helps quickly locate critical resource details. |

---

## 🧠 Why This Phase Is Important

In production, storing unencrypted data or plain passwords is a serious security risk.  
Phase 2 ensures **data confidentiality, integrity, and compliance** by introducing:

- 🔒 **KMS Encryption** — All sensitive data at rest is encrypted using a CMK.
- 🧩 **Secrets Manager** — DB credentials are generated and stored securely.
- 🗄️ **RDS in Private Subnets** — Database is isolated from public internet access.
- 🔁 **Automatic Password Rotation Ready** — Passwords can be rotated easily without downtime.

---

## 🚀 How to Deploy

1. **Initialize Terraform**
   ```bash
   terraform init

2. **Validate configuration**
   ```bash
   terraform validate

3. **Preview the plan**
   ```bash
   terraform plan

4. **Apply the infrastructure**
   ```bash
   terraform apply

5. **Verify outputs**
   ```bash
   terraform output

# Validation Checklist

| Check                  | AWS Console Path                          | Expected Result                                      |
|------------------------|-------------------------------------------|------------------------------------------------------|
| RDS Subnet Group       | RDS → Subnet Groups                       | Lists both private subnets                           |
| RDS Accessibility      | RDS → Connectivity                        | Publicly Accessible = ❌ No                          |
| Encryption             | RDS → Configuration                       | Storage encryption = ✅ Enabled                      |
| KMS Key                | KMS → Customer managed keys               | Key alias = `alias/todo-rds-kms`                    |
| Secrets Manager        | Secrets Manager                           | Secret value contains username + password            |
| Secret Encryption      | Secrets Manager → Encryption              | KMS key = your custom CMK                            |
| Connectivity           | From App EC2 → `psql -h <endpoint>`       | Works internally via private network                 |

## 🧹 Cleanup

Always destroy resources after testing to avoid ongoing AWS costs:
```bash
terraform destroy
```

# Security Highlights

| Component          | Security Measure                                           |
|--------------------|------------------------------------------------------------|
| Network            | RDS in private subnets (no public IP)                      |
| Access Control     | Only App SG can talk to RDS SG                            |
| Secrets            | Stored in AWS Secrets Manager (encrypted)                  |
| Encryption         | KMS CMK for RDS storage + secrets                         |
| IAM Principle      | Least-privilege best practices can be applied to secrets access |

## 🧭 Next Phase Preview

### Phase 3 — Application Delivery & Observability

* Load Balancer (ALB)

* ECS Cluster & Task Definition

* CloudWatch Logs & Monitoring

* Route 53 domain integration

* Remote backend (S3 + DynamoDB state locking)
