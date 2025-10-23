module "network" {
  source = "../../modules/network"
  vpc_cidr       = var.vpc_cidr
  public_cidrs   = var.public_cidrs
  private_cidrs  = var.private_cidrs
  region         = var.region
  tags           = var.tags
}
 
module "security" {
    source = "../../modules/security"
    vpc_id = module.network.vpc_id
    app_port = var.app_port
}

module "ecr" {
    source = "../../modules/ecr"
    tags = var.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/three-tier-dev"
  retention_in_days = 7
}

module "alb" {
    source = "../../modules/alb"
    vpc_id = module.network.vpc_id
    subnet_ids  = module.network.public_subnet_ids
    alb_sg_id   = module.security.alb_sg_id
    app_port    = var.app_port
    tags        = var.tags
}

module "asm" {
    source = "../../modules/asm"
    asm_name = var.asm_name
}


module "ecs" {
    source = "../../modules/ecs_service"
    repo_url = module.ecr.repository_url
    #repo_url = "nginx"
    app_port = var.app_port
    cpu = 256
    memory = 512
    subnet_ids = module.network.private_subnet_ids
    ecs_sg_id  = module.security.ecs_sg_id
    target_group_arn = module.alb.target_group_arn
    assign_public_ip = false
    log_group_name   = aws_cloudwatch_log_group.app.name
    region           = var.region
    secret_arn       = module.asm.secret_arn
}

module "rds" {
    source = "../../modules/rds"
    name = "${var.project}-db"
    engine = "postgres"
    engine_version = var.engine_version
    instance_class = var.instance_class
    allocated_storage = 20
    db_name = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    subnet_ids = module.network.private_subnet_ids
    security_group_ids = [module.security.rds_sg_id]
    tags = var.tags 
    db_secret_id = module.asm.secret_id
}

resource "random_id" "frontend_bucket_suffix" {
  byte_length = 4
}

module "frontend" {
    source = "../../modules/s3_website"
    bucket_name = "${var.project}-frontend-${random_id.frontend_bucket_suffix.hex}"
    tags = var.tags
}