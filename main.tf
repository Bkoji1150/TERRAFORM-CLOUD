
locals {
  tags = {
    name                    = "Jenkinsagent"
    Created_by              = "Terraform"
    App_Name                = "ovid"
    Cost_center             = "xyz222"
    Business_unit           = "Automation"
    App_role                = "web_server"
    Environment             = "dev"
    Security_Classification = "Internal"
  }
}

data "aws_ami" "jenkins_golden_image" {
  most_recent = true
  owners      = ["self"]

  tags = {
    Name       = "Jenkins_agent_ami"
    Created_by = "Terraform"
  }
}



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
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.jenkins_agent_policy.json
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "Jenkins-instance-role"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "Jenkins-instance-role"

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

resource "aws_ssm_parameter" "cloudwatch_agent" {

  name        = "jenkins"
  description = "Value for the aws cloudwatch agent on jenkins agents"
  type        = "String"
  tier        = "Standard"
  data_type   = "text"
  value       = file("templates/cloudwatch-config.json")
}

resource "aws_launch_template" "launch_template" {
  name_prefix            = "hqr-jenkins-agent-lt-"
  image_id               = data.aws_ami.jenkins_golden_image.id
  instance_type          = var.instance_type
  update_default_version = true
  ebs_optimized          = true
  iam_instance_profile {

    arn = aws_iam_instance_profile.ec2_profile.arn
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }
  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  user_data = base64encode(
    templatefile(
      "./templates/user_data.sh.tpl",
      {
        "ansible_version"  = var.ansible_version,
        "cwa_config_param" = aws_ssm_parameter.cloudwatch_agent.name
      }
    )
  )
}

resource "aws_autoscaling_group" "asg" {
  name_prefix               = "hqr-jenkins-agent-"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["subnet-42046d4c", "subnet-d6c6819b"]
  termination_policies      = ["OldestLaunchTemplate", "OldestInstance", ]
  suspended_processes       = []
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  # initial_lifecycle_hook {}
  tags = flatten([
    [for k, v in local.tags : v != null ? { "key" = k, "value" = v, "propagate_at_launch" = true } : {}],
    [{ "key" = "Name", "value" = "jenkins-build-agent", "propagate_at_launch" = true }]
  ])
  enabled_metrics = var.enabled_metrics
}
