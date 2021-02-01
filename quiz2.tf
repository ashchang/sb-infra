resource "aws_ecs_cluster" "sb2" {
  name = "feature"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "sb2" {
  family                   = "feature"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = file("./feature.json")
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution.arn
}

resource "aws_ecs_service" "sb2" {
  name            = "feature"
  cluster         = aws_ecs_cluster.sb2.id
  task_definition = aws_ecs_task_definition.sb2.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = 30

  network_configuration {
    security_groups = [aws_security_group.sb.id]
    subnets         = module.vpc.public_subnets
    assign_public_ip= true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sb-alb-tg.id
    container_name   = "feature"
    container_port   = 3000
  }

  tags = {
    "branch" = "feature/1"
  }
}

resource "aws_cloudwatch_log_group" "sb2" {
  name = "/ecs/feature"
  retention_in_days = 7
}