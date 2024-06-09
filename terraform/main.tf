provider "aws" {
  region = "us-east-1" # Change this to your desired region
}

resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "hello_world_task" {
  family                   = "hello-world-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "hello-world-container",
      "image": "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/hello-world-app:${tag}",
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
    subnets         = ["subnet-12345678"] # Change this to your subnet IDs
    security_groups = ["sg-12345678"]     # Change this to your security group IDs
    assign_public_ip = true
  }
}
