## 🧩 Bonus — Automate DNS, SSL & HTTPS with Terraform

This section shows how to fully automate everything you previously did through the AWS Console — including Route 53 DNS, SSL certificates (ACM), and ALB HTTPS listeners — **all with Terraform**.

You’ll have complete Infrastructure-as-Code (IaC) control: DNS, SSL, HTTPS, and redirection handled automatically, without any manual clicks.

### 🧩 Automate Route 53 DNS Records with Terraform

**Why this is required:**  
Instead of manually creating DNS records in the AWS Console, Terraform lets you define them as code.
This makes it easy to version-control, reuse, and reproduce your entire DNS setup for future projects or environments.
```
# route53.tf
resource "aws_route53_zone" "main" {
  name = "learnforge.site"
}

# A record for root domain → GitHub Pages IPs
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "learnforge.site"
  type    = "A"
  ttl     = 300
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}

# CNAME for www → GitHub Pages default
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = ["akhemani.github.io"]
}

# Alias record for API → Application Load Balancer
data "aws_lb" "app_alb" {
  name = "todo-app-alb" # replace with your ALB name
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api"
  type    = "A"

  alias {
    name                   = data.aws_lb.app_alb.dns_name
    zone_id                = data.aws_lb.app_alb.zone_id
    evaluate_target_health = false
  }
}
```

**What happens next:**  
Running terraform apply will automatically create all Route 53 records — no console clicks needed.
Your frontend and backend DNS setup will stay consistent across environments, and any future change can be tracked through Git commits.

---

## 🔐 Automate SSL & HTTPS for ALB via Terraform

**Why this is required:**  
To make your backend (api.learnforge.site) secure by default, you can use Terraform to request an ACM certificate and attach it to your Application Load Balancer automatically.
This eliminates manual clicks in AWS Console and ensures your HTTPS setup is consistent, versioned, and reproducible.
```
# acm.tf
resource "aws_acm_certificate" "api_cert" {
  domain_name               = "api.learnforge.site"
  subject_alternative_names = ["learnforge.site"]
  validation_method          = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Automatically create DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "api_cert_validation" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# alb-listeners.tf
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.todo_app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.api_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_ecs_tg.arn
  }
}

# Redirect HTTP to HTTPS
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

**What happens next:**  
When you run terraform apply, it will automatically:
* Request and validate an SSL certificate for your domain via ACM,
* Attach it to your ALB’s HTTPS listener, and
* Set up an automatic HTTP → HTTPS redirect.

No manual steps are needed — you get a fully secured ALB with HTTPS enforced.

---

### 🧱 Complete Terraform Integration Summary
| **Component**                          | **Terraform File**     | **Purpose**                            |
|----------------------------------------|------------------------|----------------------------------------|
| Route 53 Hosted Zone + Records        | `route53.tf`           | Manages DNS for frontend & backend     |
| ACM Certificate + Validation           | `acm.tf`               | Requests and validates SSL cert        |
| ALB HTTPS Listeners                    | `alb-listeners.tf`     | Enforces HTTPS + redirects HTTP        |
| ECS, RDS, and Networking (existing files) | (existing files)      | Application + database layer          |


### 🏁 Final Result — 100% Automated Infrastructure
✅ DNS (Route 53) → Infrastructure-as-code  
✅ SSL (ACM) → Automatically issued & validated  
✅ HTTPS (ALB) → Managed by Terraform  
✅ CI/CD (GitHub Actions) → Automated frontend deployment  
✅ Backend (ECS + RDS) → Secured & modularized  

Your entire 3-tier application — frontend, backend, and domain setup — is now **fully automated, reproducible, and production-ready. 🚀**
