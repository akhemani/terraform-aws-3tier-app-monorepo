# 🪜 Phase 1 — Core Network & Compute (Base Infrastructure)

This Terraform project lays the **foundation of a secure 3-tier architecture on AWS**.  
It builds the **VPC, subnets, internet & NAT gateways, route tables**, and deploys two EC2 instances (web + app).  
Later phases will extend this with RDS, Secrets Manager, ECS, Load Balancer, and Route 53.

---

## 🎯 Project Objective
Create a reliable, scalable, and secure **network & compute layer** using Terraform.

After applying this configuration, you’ll have:
- 1 VPC  
- 2 Public subnets (for web + future load balancer)  
- 2 Private subnets (for app + database)  
- Internet Gateway & NAT Gateway  
- Proper route tables and associations  
- Security groups for Web and App layers  
- Two EC2 instances (web + app)

---

## 📁 Directory Structure

```phase-1/
├── provider.tf # Provider configuration (AWS)
├── variables.tf # Input variables (region, CIDRs, key pair)
├── vpc.tf # VPC, subnets, gateways, routes
├── security-groups.tf # Web & App security groups
├── ec2.tf # EC2 instances (web & app)
├── outputs.tf # Useful outputs (IPs, VPC ID)
└── .gitignore # Excludes state files & secrets
```


---

## ⚙️ What Each File Does

| File | What | Why |
|------|------|-----|
| **provider.tf** | Declares the AWS provider and region. | Tells Terraform where to create resources. |
| **variables.tf** | Stores reusable inputs like region, subnet CIDRs, key pair name. | Makes configuration cleaner and easier to update. |
| **vpc.tf** | Creates VPC, public/private subnets, Internet Gateway, NAT Gateway, Elastic IP, route tables, and associations. | Builds the core network architecture and defines traffic flow. |
| **security-groups.tf** | Defines Web and App security groups and ingress/egress rules. | Controls which resources and ports are accessible. |
| **ec2.tf** | Launches one public (Web) EC2 and one private (App) EC2. | Represents web and application layers. |
| **outputs.tf** | Prints key outputs (e.g., public IP of web EC2). | Helps validate deployment quickly. |
| **.gitignore** | Ignores tfstate, .tfvars, .pem files. | Prevents leaking credentials or state. |

---

## 🧠 Why This Phase Matters
Phase 1 creates the **foundation** that all later services will depend on:
- Networking isolation (public vs private).
- Secure SSH & HTTP access.
- Outbound internet from private subnets via NAT.
- Tested EC2 compute layer for web and app services.

---

## 🚀 How to Deploy

1. **Initialize Terraform**
   ```bash
   terraform init

2. **Review the Execution Plan**
   ```bash
   terraform plan

1. **Apply the Configuration**
   ```bash
   terraform apply

4. **Destroy Resources**
   ```bash
   terraform destroy

## 🧩 Validation Checklist

| Test | Command | Expected Result |
|------|---------|-----------------|
| **SSH to Web EC2** | `ssh -i key.pem ubuntu@<web_public_ip>` | ✅ Connects successfully |
| **Internet from Web EC2** | `curl https://google.com` | ✅ Works |
| **Internet from App EC2 (via NAT)** | `ssh -i key.pem ubuntu@<web_public_ip>` → `ssh ubuntu@<app_private_ip>` → `sudo apt update` | ✅ Works |
| **Routing Tables** | AWS Console → VPC → Route Tables | ✅ Public subnets route via **IGW**, Private subnets route via **NAT Gateway** |

### ✅ Notes:
- Replace `<web_public_ip>` and `<app_private_ip>` with actual IP addresses from your AWS console.
- Ensure your **security groups** and **key pair** allow SSH access.
- Internet access in private subnets depends on proper **NAT Gateway** and **route table association**.

## 🔒 Security Notes

* SSH (22) is allowed only from your IP in security-groups.tf.

* HTTP (80) is open to the public for testing.

* App EC2 has no public IP and only accepts traffic from Web SG.

* Terraform state and key files are excluded via .gitignore.

## 🧭 Next Phase Preview

**Phase 2 — Data & Secrets Layer**

* Add RDS (PostgreSQL) in private subnets

* Generate random passwords

* Store credentials in AWS Secrets Manager

* Encrypt data using KMS keys