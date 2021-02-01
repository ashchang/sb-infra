# for ECS taskdef to get account number
resource "aws_ssm_parameter" "ssm_account_id" {
  name  = "/sb/ACCOUNT_ID"
  type  = "String"
  value = var.account_id
}

# ALB and Target Group(TG)
resource "aws_lb" "sb-alb" {
  name               = var.app_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sb-lb-sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "sb-alb-listener" {
  load_balancer_arn = aws_lb.sb-alb.id
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_lb_target_group.sb-alb-tg.id
    type             = "forward"
  }

  depends_on = [ aws_lb_target_group.sb-alb-tg ]
}

resource "aws_lb_target_group" "sb-alb-tg" {
    name = var.app_name
    port = var.app_port
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = module.vpc.vpc_id
    depends_on = [ aws_lb.sb-alb ]
    load_balancing_algorithm_type = "least_outstanding_requests"
}

# Security Group
resource "aws_security_group" "sb-lb-sg" {
    name = "sb-lb-sg"
    vpc_id = module.vpc.vpc_id
    tags = {
        Name = "sb-lb-sg"
    }

    ingress {
        description = "TLS from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sb" {
    name = "sb-sg"
    vpc_id = module.vpc.vpc_id
    tags = {
        Name = "sb"
    }

    ingress {
        description = "TLS from VPC"
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        security_groups = [aws_security_group.sb-lb-sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_ecs_cluster" "sb" {
  name = var.app_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "sb" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = file("./taskdef.json")
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution.arn
}

resource "aws_ecs_service" "sb" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.sb.id
  task_definition = aws_ecs_task_definition.sb.arn
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
    container_name   = var.app_name
    container_port   = var.app_port
  }

  tags = {
    "branch" = "sb"
  }
}

resource "aws_cloudwatch_log_group" "sb" {
  name = "/ecs/${var.app_name}"
  retention_in_days = 7
}
