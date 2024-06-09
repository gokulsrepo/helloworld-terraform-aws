provider "aws" {
  region = var.aws_region
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "tag" {
  type    = string
  default = "latest"
}

# Check if the IAM role already exists
data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role" "ecs_task_execution" {
  count = length(data.aws_iam_role.existing_ecs_task_execution_role.arn) == 0 ? 1 : 0
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  count = length(data.aws_iam_role.existing_ecs_task_execution_role.arn) == 0 ? 1 : 0
  name = "ecsTaskExecutionPolicy"
  role = length(data.aws_iam_role.existing_ecs_task_execution_role.arn) == 0 ? aws_iam_role.ecs_task_execution.id : data.aws_iam_role.existing_ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "hello_world_task" {
  family                   = "hello-world-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = length(data.aws_iam_role.existing_ecs_task_execution_role.arn) == 0 ? aws_iam_role.ecs_task_execution.arn : data.aws_iam_role.existing_ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "hello-world-container",
      "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/hello-world-app:${var.tag}",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "hello_world_service" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.hello_world_cluster.id
  task_definition = aws_ecs_task_definition.hello_world_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}