locals {
  bucket_name = "gokulb-tf-bucket"
  table_name  = "gokulb-tf-table"

  ecr_repo_name = "hello-world-ecr"

  demo_app_cluster_name        = "hello-world-cluster"
  availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  demo_app_task_famliy         = "hello-world-task"
  container_port               = 3000
  demo_app_task_name           = "hello-world-task"
  ecs_task_execution_role_name = "hello-world-task-execution-role"

  application_load_balancer_name = "hello-world-lb"
  target_group_name              = "heelo-world-tg"

  demo_app_service_name = "hello-world-service"
}