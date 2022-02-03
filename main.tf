
locals {
  tags = {
    name                    = "JenkinsMaster"
    Created_by              = "Terraform"
    App_Name                = "ovid"
    Cost_center             = "xyz222"
    Business_unit           = "Automation"
    App_role                = "web_server"
    Environment             = "dev"
    Security_Classification = "Internal"
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
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
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
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

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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


resource "aws_key_pair" "key" {
  key_name   = "id_rsa"
  public_key = file(var.public_key_path)
}

resource "aws_ssm_parameter" "cloudwatch_agent" {

  name        = "jenkins"
  description = "Value for the aws cloudwatch agent on jenkins agents"
  type        = "String"
  tier        = "Standard"
  data_type   = "text"
  value       = file("./cloudwatch-config.json")
  tags        = local.tags
}

resource "aws_launch_template" "launch_template" {
  name_prefix            = "hqr-jenkins-agent-lt-"
  image_id               = var.ami
  instance_type          = var.instance_type
  update_default_version = true
  ebs_optimized          = true
  iam_instance_profile {
    # Should be: arn:aws:iam::354979567826:instance-profile/EC2-Hostname
    # Needs more permissions until all libraries use the new pipeline or
    # are updated to use the IAM User
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
  # vpc_security_group_ids = flatten([
  #   data.aws_security_groups.agent_mgt_sg.ids,
  #   aws_security_group.allow_jenkins_cje.id
  # ])
  user_data = base64encode(
    templatefile(
      "./templates/user_data.sh.tpl",
      {
        # "ansible_version"  = var.ansible_playbook_version,
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
  enabled_metrics = [
    "GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity",
    "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances",
    "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity",
    "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"
  ]
  # service_linked_role_arn =
}
