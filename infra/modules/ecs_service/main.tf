###############################
# IAM Execution Role
###############################


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Policy to allow ECS tasks to read Secrets Manager secrets
resource "aws_iam_policy" "ecs_secrets" {
  name   = "ecs-access-secrets"
  policy = data.aws_iam_policy_document.ecs_secrets.json
}

# Attach the secrets access policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_exec_can_read_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets.arn
}



###########################
# ECS Cluster + Task + Svc
###########################
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
     operating_system_family = "LINUX"
     cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
  {
      name  = "app-container"
      image = "${var.repo_url}:latest"
      #image = "${aws_ecr_repository.app_repo.repository_url}:latest"
     

      portMappings = [
        {  
            containerPort = var.app_port, 
            hostPort      = var.app_port,
            protocol      = "tcp" 
        }
      ]
      environment = [
        {
          name  = "PORT"
          value = "8080"
        }
      ]
      secrets = [
        { name = "DATABASE_URL", valueFrom = "${var.secret_arn}:database_url::" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.log_group_name}"
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

#####################
# ECS Service (Fargate)
#####################
resource "aws_ecs_service" "app_service" {
  name            = "${var.project}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app-container"
    container_port   = var.app_port
  }

  lifecycle {
    ignore_changes = [ desired_count  ]
  }

}