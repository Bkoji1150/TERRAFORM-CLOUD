
data "aws_iam_policy_document" "jenkins_agent_policy" {

  statement {
    sid    = "AllowSpecifics"
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "application-autoscaling:*",
      "autoscaling:*",
      "apigateway:*",
      "cloudfront:*",
      "cloudwatch:*",
      "cloudformation:*",
      "dax:*",
      "dynamodb:*",
      "ec2:*",
      "ec2messages:*",
      "ecr:*",
      "ecs:*",
      "elasticfilesystem:*",
      "elasticache:*",
      "elasticloadbalancing:*",
      "es:*",
      "events:*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "rds:*",
      "route53:*",
      "ssm:*",
      "ssmmessages:*",
      "s3:*",
      "sns:*",
      "sqs:*",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
  }
  statement {
    sid    = "DenySpecifics"
    effect = "Deny"
    resources = [
      "*"
    ]
    actions = [
      "aws-marketplace-management:*",
      "aws-marketplace:*",
      "aws-portal:*",
      "budgets:*",
      "config:*",
      "directconnect:*",
      "ec2:*ReservedInstances*",
      "iam:*Group*",
      "iam:*Login*",
      "iam:*Provider*",
      "iam:*User*",
    ]
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name   = "${var.component_name}-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.jenkins_agent_policy.json
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "${var.component_name}-ec2-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.component_name}-instance-role"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.component_name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
