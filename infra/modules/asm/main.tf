resource "aws_secretsmanager_secret" "db_secrets" {
  name = var.asm_name
}