# Use random_password resource to generate a 16-character password.
# Store it in aws_secretsmanager_secret.
# Add a version (aws_secretsmanager_secret_version) that contains:

# ----------------Random password for RDS---------------------
resource "random_password" "rds_password" {
  length  = 16
  special = false
}

# ----------------Secrets Manager secret---------------------
resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "todo-rds-password"
  description = "RDS DB password stored securely"
  kms_key_id  = aws_kms_key.rds_kms.id
}

# ----------------Secret version (actual value)---------------------
resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds_password.result
  })
}
