resource "random_password" "rds_password" {
  length  = 16
  special = true
}


resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.rds_password.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.security_group_ids
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  skip_final_snapshot     = true
  deletion_protection     = false
  tags                    = var.tags
}


resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = var.db_secret_id
  secret_string = jsonencode({
    username = aws_db_instance.this.username
    password = random_password.rds_password.result
    host     = aws_db_instance.this.address
    port     = 5432
    dbname   = aws_db_instance.this.db_name
    database_url = "postgres://${aws_db_instance.this.username}:${urlencode(random_password.rds_password.result)}@${aws_db_instance.this.address}:5432/${aws_db_instance.this.db_name}?sslmode=require"
  })
}

