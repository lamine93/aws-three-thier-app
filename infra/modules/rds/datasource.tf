locals {
  database_url = "postgres://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.address}:5432/${aws_db_instance.this.db_name}"
}