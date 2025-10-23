output "secret_id" {
  value = aws_secretsmanager_secret.db_secrets.id
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_secrets.arn
}