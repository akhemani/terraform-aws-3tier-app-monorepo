# 🚀 Terraform AWS 3-Tier App — Monorepo Base Setup

This repository is the **base monorepo** for a full-stack 3-tier cloud application project.  
It combines **frontend (Angular)**, **backend (Spring Boot)**, and **infrastructure (Terraform)** under a single unified repo.

> 🧱 This `main` branch contains only the *bare minimum* backend & frontend setup with GitHub Actions configured for automated CI/CD.  
> Infrastructure-as-Code (Terraform) will be added and evolved across separate branches (`infra/phase-*`).

---

## 📂 Monorepo Structure

```bash
terraform-aws-3tier-app-monorepo/
├── backend/                  # Spring Boot backend (minimal API setup)
│   ├── src/...
│   ├── pom.xml
│   └── Dockerfile
│
├── frontend/                 # Angular frontend (placeholder UI)
│   ├── src/...
│   ├── angular.json
│   └── package.json
│
└── .github/
    └── workflows/
        ├── backend-deploy.yml    # Builds & pushes backend Docker image to Amazon ECR
        └── frontend-pages.yml    # Builds & deploys Angular app to GitHub Pages
```
## ⚙️ GitHub Actions Workflows
### 🐳 Backend — Build & Push to Amazon ECR
* **File:** `.github/workflows/backend-deploy.yml`
* **Triggers:** On push to `main` affecting `backend/**`
* **Key steps:**
    * Builds Docker image for Spring Boot app
    * Pushes image to Amazon Elastic Container Registry (ECR)
    * Uses GitHub Secrets:
        * AWS_ACCESS_KEY_ID
        * AWS_SECRET_ACCESS_KEY
✅ Purpose: Automates backend image build & push, ready for ECS deployment in later Terraform phases.

### 🌐 Frontend — Deploy Angular to GitHub Pages
* **File:** `.github/workflows/frontend-pages.yml`
* **Triggers:** On push to `main` affecting `frontend/**`
* **Key steps:**
    * Installs Node.js and dependencies
    * Builds Angular app
    * Deploys static site to **GitHub Pages**
    * Configures a **custom domain** → `https://learnforge.site`

✅ Purpose: Automates frontend deployment directly from main branch.

### 🪜 Future Roadmap (Terraform Phases)
This repo will evolve in phases — each Terraform stage lives in its own branch:

| Phase | Branch | Description |
|-------|--------|-------------|
| 🧩 Phase 1 | `infra/phase-1-core-network` | VPC, subnets, routing, EC2 base |
| 🔐 Phase 2 | `infra/phase-2-data-security` | RDS + Secrets Manager + KMS |
| ⚙️ Phase 3 | `infra/phase-3-app-tier` | ECS + ALB + AutoScaling |
| 🌐 Phase 4 | `infra/phase-4-dns-ssl` | Route53 + ACM + HTTPS setup |

Each phase adds a new layer of infrastructure while keeping IaC modular and secure.

### 🧠 Tech Stack Overview
## Architecture Layers

| Layer       | Technology          | Description                                           |
|-------------|---------------------|-------------------------------------------------------|
| **Frontend**    | Angular             | Deployed via GitHub Pages                             |
| **Backend**     | Spring Boot         | Dockerized, pushed to Amazon ECR                      |
| **CI/CD**       | GitHub Actions      | Automated builds & deployments                        |
| **Infra (Upcoming)** | Terraform + AWS | Full 3-tier cloud setup (VPC, ECS, RDS, ALB, Route53, etc.) |

### 🔒 Required GitHub Secrets
To enable CI/CD pipelines, add these secrets in your repo settings **→ Settings → Secrets → Actions**

## GitHub Secrets

| Secret Name             | Purpose                                              |
|-------------------------|------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | IAM user access key for GitHub Actions               |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key                                  |

(Optional later) `AWS_REGION`, `ECR_REPOSITORY` can be overridden in workflows	

### 🧭 Branching Convention
## Git Branching Strategy

| Branch                  | Purpose                                           |
|-------------------------|---------------------------------------------------|
| `main`                  | Base monorepo with minimal backend/frontend & workflows |
| `base-monorepo-setup`   | Snapshot of this starting state                   |
| `infra/phase-*`         | Terraform IaC evolution                           |
| `feature/*`             | New app features                                  |
| `hotfix/*`              | Urgent fixes                                      |
| `docs/*`                | Documentation & blog updates                      |

### 🧩 About This Project
This monorepo serves as the foundation for a **complete AWS-hosted 3-tier application**, built fully via **Infrastructure-as-Code (Terraform)** and automated via **GitHub Actions**.

Future iterations will:

* Add secure RDS (PostgreSQL) setup
* Integrate KMS encryption and Secrets Manager
* Deploy backend on ECS with ALB & HTTPS
* Manage DNS & SSL via Route53 + ACM
* Enable CI/CD for infrastructure as well

#### 📘 Next Step: Checkout the branch infra/phase-1-core-network to start exploring the Terraform network foundation.
