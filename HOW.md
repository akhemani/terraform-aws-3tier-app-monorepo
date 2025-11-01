# 🌐 Connect a GoDaddy Domain to GitHub Pages (Frontend) & AWS (ECS/ALB/RDS) with HTTPS

This walkthrough shows how to wire a **GoDaddy domain** (`learnforge.site`) to:

- **GitHub Pages frontend** at → `https://learnforge.site`  
- **AWS backend (ECS + ALB + RDS)** at → `https://api.learnforge.site`, 
    all secured **end-to-end with HTTPS**.
---

### 🧠 Architecture at a Glance
```
Browser
├─ https://learnforge.site → GitHub Pages (Frontend)
└─ https://api.learnforge.site → AWS ALB → ECS (Spring Boot) → RDS (PostgreSQL)
```
| Layer     | Service                 | Domain                  | Security             |
|---------|-------------------------|-------------------------|----------------------|
| Frontend  | GitHub Pages            | `https://learnforge.site` | HTTPS (GitHub managed) |
| Backend   | AWS ECS + ALB + RDS     | `https://api.learnforge.site` | HTTPS (ACM managed) |
| DNS       | Route 53                | `learnforge.site`       | Records for both front/back |

---

## 🪜 Step 1 — Create a Public Hosted Zone in Route 53

**Why this is required:**  
To control DNS records (A, CNAME, etc.) for your custom domain from AWS, you need a hosted zone in Route 53. This zone acts as your domain’s DNS manager inside AWS.

AWS Console → Route 53 → Hosted zones → Create hosted zone  
Domain name: `learnforge.site`  
Copy the **4 NS (name server)** values Route 53 shows.

You’ll point GoDaddy to these name servers next.

**What happens next:**  
Your domain now has a DNS container ready in AWS. Once GoDaddy points to these name servers, **AWS Route 53 will start managing your domain’s DNS records.**

---

## 🪜 Step 2 — Point GoDaddy to Route 53

**Why this is required:**  
GoDaddy is your registrar (where the domain was purchased), but Route 53 will manage your DNS. You need to tell GoDaddy to delegate all DNS control to Route 53.

GoDaddy → Domains → learnforge.site → DNS (Manage DNS)  
Nameservers → Change → Enter my own nameservers  
Paste the 4 Route 53 NS values and Save.

⏳ Wait ~10–30 minutes for DNS propagation.

**What happens next:**  
GoDaddy will now direct all DNS queries for your domain to AWS Route 53. From here on, any A or CNAME record changes you make in Route 53 will affect your live domain.

---

## 🪜 Step 3 — Route 53 Records for the Frontend (GitHub Pages)

**Why this is required:**  
Your frontend (static site) is hosted on GitHub Pages, so we must map the domain learnforge.site to GitHub’s servers using Route 53 records.

At the zone apex (learnforge.site) you cannot use a CNAME. Use a single **A record** containing all 4 GitHub Pages IPs.

Route 53 → Hosted zone → learnforge.site → Create record

Create one **A record** (leave name blank) with these 4 IPs (one per line):
```
185.199.108.153  
185.199.109.153  
185.199.110.153  
185.199.111.153
```

(Optional) Create `www` as a **CNAME → akhemani.github.io.**

This maps:

* `learnforge.site` → GitHub Pages
* `www.learnforge.site` → akhemani.github.io

**What happens next:**  
Your domain now resolves directly to GitHub Pages’ servers. Once you configure Pages, `https://learnforge.site` will open your frontend website.

---

## 🪜 Step 4 — Configure GitHub Pages (Custom Domain + HTTPS)

**Why this is required:**  
GitHub Pages needs to recognize your custom domain and automatically issue a free HTTPS certificate via Let’s Encrypt.

Repo: https://github.com/akhemani/terraform-aws-3tier-app-monorepo

Settings → Pages  
Source: GitHub Actions  
Custom domain: learnforge.site  
Enable Enforce HTTPS ✅

GitHub will issue a Let’s Encrypt cert (usually 5–15 minutes).

**What happens next:**  
Your frontend will be served securely over HTTPS using GitHub’s certificate, and browsers will show the padlock icon for your domain.

---

## 🪜 Step 5 — Route 53 Record for the Backend (ALB)

**Why this is required:**  
Your backend lives behind an Application Load Balancer (ALB) on AWS. You need a DNS record to map `api.learnforge.site` to your ALB’s public endpoint.

Create an A (Alias) record for your ALB:  
Route 53 → Hosted zone → learnforge.site → Create record
```
Name: api  
Record type: A  
Alias: Yes → pick your ALB (e.g., todo-app-alb-…elb.amazonaws.com)
```

Now `api.learnforge.site` resolves to your ALB.

**What happens next:**  
The subdomain api.learnforge.site will start routing requests to your ALB, which forwards traffic to your ECS containers.

---

## 🪜 Step 6 — Issue an SSL Certificate in ACM (for the ALB)

**Why this is required:**  
Your ALB needs an SSL certificate to handle HTTPS traffic securely. AWS Certificate Manager (ACM) provides free public certificates for this.

AWS → Certificate Manager (ACM) (region us-east-1)  
Request a public certificate  
Add:
```
api.learnforge.site  
learnforge.site
```

Choose **DNS validation** → ACM can auto-create validation CNAMEs in Route 53.  
Wait for status **Issued**.

You’ll attach this cert to your ALB HTTPS listener next.

**What happens next:**  
Your ALB can now terminate HTTPS connections using this certificate, ensuring encrypted communication between users and your backend.

---

## 🪜 Step 7 — Add HTTPS to the ALB (+ Redirect HTTP→HTTPS)

**Why this is required:**  
By default, your ALB only handles HTTP traffic. To enforce security and modern best practices, we’ll add HTTPS and redirect all HTTP requests to HTTPS.

In Terraform (example):

```hcl
# variables.tf
variable "acm_certificate_arn" {
  description = "ACM cert ARN for api.learnforge.site"
  type        = string
}

# alb.tf
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.todo_app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_ecs_tg.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.todo_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
```
Ensure your Target Group is `target_type = "ip"` and port = 8080 (your container port).  
ALB SG must allow 80 & 443 from the internet.  
ECS/App SG must allow 8080 inbound from ALB SG.

**What happens next:**  
Your backend is now fully accessible via HTTPS. All HTTP traffic will automatically redirect to the secure version, improving SEO and security.

## 🪜 Step 8 — Frontend → Backend URL

> **Why this is required:**
Your frontend app must call the backend using HTTPS and the correct subdomain to prevent mixed-content and CORS issues.

In your frontend code, set the API base URL to HTTPS:
```
export const API_BASE = 'https://api.learnforge.site';
```

Never call `http://…` from `https://learnforge.site` (browsers will block mixed content).

> **What happens next:**
Your frontend’s API calls will securely reach your backend via HTTPS, maintaining end-to-end encryption for all user interactions.

## 🪜 Step 9 — Frontend CI/CD (GitHub Pages via Actions)

> **Why this is required:**
Manual deployment is error-prone. Using GitHub Actions automates build and deployment whenever code is pushed, ensuring your frontend is always live and up-to-date.

#### Once per repo (Settings):
* Settings → Pages
    * Source: GitHub Actions
    * Custom domain: learnforge.site
    * Enforce HTTPS: ✅

#### Angular tweaks (if using Angular):
* Ensure build outputs to `dist/frontend` (or your path).
* Use base href `/` for the root domain:
```
npx ng build --configuration production --base-href /
```

SPA fallback: copy `index.html` to `404.html` in the built output.

Workflow file: `.github/workflows/frontend-pages.yml`
```
name: Frontend - Build & Deploy to GitHub Pages
on:
  push:
    branches: [ main ]
    paths:
      - 'frontend/**'
      - '.github/workflows/frontend-pages.yml'
  workflow_dispatch:
...
```

(code unchanged for brevity)

For React/Vite: use `npm run build` and set the Pages artifact path to your output (`frontend/build` or `frontend/dist`). Keep the CNAME and optional 404.html.

#### What happens next:
Every push to `main` automatically builds and deploys your frontend. Within seconds, your site at `learnforge.site` will reflect the latest version.

## 🪜 Step 10 — Validate End-to-End

**Why this is required:**
> Before you celebrate, confirm that both DNS and HTTPS are working properly for frontend and backend.

DNS:
```
dig learnforge.site +short
# Expect the 4 GitHub IPs

dig api.learnforge.site +short
# Expect your ALB DNS name
```

Frontend:
```
curl -I https://learnforge.site
# Expect 200 OK and a valid certificate (GitHub Pages)
```

Backend:
```
curl -I https://api.learnforge.site/welcome
# Expect 200 OK (your Spring Boot endpoint)
```

Browser (DevTools → Network):
* App loads from https://learnforge.site
* API calls go to https://api.learnforge.site
* No mixed-content/CORS errors

**What happens next:**
> You’ve confirmed DNS, SSL, and routing for both sides — your full stack is securely live and production-ready.

### 🧰 Security Group Checklist (Quick)
```
Resource	  Inbound	                Outbound
ALB SG	      80, 443 from 0.0.0.0/0	All
App/ECS SG	  8080 from ALB SG	        All
RDS SG	      5432 from App/ECS SG	    All
```
### ✅ Done

You now have:

* A custom domain (learnforge.site) on GitHub Pages for your frontend
* A secure backend at api.learnforge.site on AWS
* DNS centralized in Route 53
* Full HTTPS on both ends
* A reproducible CI/CD workflow for the frontend
