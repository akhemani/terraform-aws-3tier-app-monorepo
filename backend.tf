terraform {
  backend "s3" {
    bucket         = "my-3-tier-aws-terraform-state-bucket"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
