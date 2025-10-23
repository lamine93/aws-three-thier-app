output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "db_arn" {
  description = "ARN of the DB instance"
  value       = aws_db_instance.this.arn
}

output "database_url" {
  description = "Database connection URL"
  value       = local.database_url
}
