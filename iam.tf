# ===========================================
# ECS Task Execution Role and Policy
# ===========================================

data "aws_iam_policy_document" "task_execution" {
  statement {
    actions = [
      "ecr:*",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task_execution" {
  name = "fargate_task_execution"
  role = aws_iam_role.task_execution.name
  policy = data.aws_iam_policy_document.task_execution.json
}

resource "aws_iam_role" "task_execution" {
  name = "fargate_task_execution"

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ROLE
}

# ===========================================
# ECS Fargate Role and Policy
# ===========================================
data "aws_iam_policy_document" "task_role" {
  statement {
    actions = [
      "cloudwatch:*",
      "logs:*",
      "ecr:*",
      "ecs:*",
      "iam:PassRole",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task_role" {
  name   = "fargate_task_role"
  role = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role.json
}

resource "aws_iam_role" "task_role" {
    name = "fargate_task_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# ===========================================
# Codebuild Policy
# ===========================================
data "aws_iam_policy_document" "example" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
      ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission"
    ]
    resources = ["*"]
  }

  # statement {
  #   actions = [
  #     "s3:*"
  #   ]
  #   resources = [
  #     aws_s3_bucket.example.arn,
  #     "${aws_s3_bucket.example.arn}/*"
  #   ]
  # }

  statement {
    actions = [
      "ssm:*",
      "ecs:*",
      "ecr:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.name
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ROLE
}