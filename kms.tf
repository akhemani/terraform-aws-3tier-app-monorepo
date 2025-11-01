# Create aws_kms_key with enable_key_rotation = true for yearly rotation.
# Add an alias (like alias/todo-rds-kms) for easy identification.

# ----------------KMS Key---------------------
resource "aws_kms_key" "rds_kms" {
  description             = "KMS key for encrypting RDS and Secrets"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "todo-kms-key"
  }
}

# ----------------Aliasing Key---------------------
resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/todo-rds-kms"
  target_key_id = aws_kms_key.rds_kms.id
}
