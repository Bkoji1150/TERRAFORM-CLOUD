
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


resource "aws_key_pair" "queens_key_auth" {
  key_name   = var.keypair_name
  public_key = file(var.public_key_path)
}

resource "aws_ssm_parameter" "cloud_agent" {

  name        = "jenkins"
  description = "Value for the aws cloudwatch agent on jenkins agents"
  type        = "String"
  tier        = "Standard"
  data_type   = "text"
  value       = file("./cloudwatch-config.json")
  tags        = local.tags
}

module "asg" {
  source = "../.."
  # Autoscaling group
  name = "example-asg"

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  #   vpc_zone_identifier       = ["subnet-1235678", "subnet-87654321"]

  initial_lifecycle_hooks = [
    {
      name                  = "ExampleStartupLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 60
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "ExampleTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  lt_name                = "example-asg"
  description            = "Launch template example"
  update_default_version = true

  use_lt    = true
  create_lt = true

  image_id          = "ami-ebd02392"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
      }, {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  cpu_options = {
    core_count       = 1
    threads_per_core = 1
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  instance_market_options = {
    market_type = "spot"
    spot_options = {
      block_duration_minutes = 60
    }
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = ["sg-12345678"]
    },
    {
      delete_on_termination = true
      description           = "eth1"
      device_index          = 1
      security_groups       = ["sg-12345678"]
    }
  ]

  placement = {
    availability_zone = "us-west-1b"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { WhatAmI = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = { WhatAmI = "Volume" }
    },
    {
      resource_type = "spot-instances-request"
      tags          = { WhatAmI = "SpotInstanceRequest" }
    }
  ]

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}

/*
resource "aws_launch_template" "launch_template" {
  name_prefix            = "hqr-jenkins-agent-lt-"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.instance_type
  update_default_version = true
  ebs_optimized          = true
  iam_instance_profile {
    # Should be: arn:aws:iam::354979567826:instance-profile/EC2-Hostname
    # Needs more permissions until all libraries use the new pipeline or
    # are updated to use the IAM User
    arn = module.iam_role.instance_profile_arn
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
    tags          = module.tags.tags
  }
  vpc_security_group_ids = flatten([
    data.aws_security_groups.agent_mgt_sg.ids,
    aws_security_group.allow_jenkins_cje.id
  ])
  user_data = base64encode(
    templatefile(
        "./templates/user-data.sh.tpl",
      {
        "ansible_version"  = var.ansible_playbook_version,
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
  vpc_zone_identifier       = data.aws_subnet_ids.mgt_subnets.ids
  termination_policies      = ["OldestLaunchTemplate", "OldestInstance", ]
  suspended_processes       = []
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  # initial_lifecycle_hook {}
  tags = flatten([
    [for k, v in module.tags.tags : v != null ? { "key" = k, "value" = v, "propagate_at_launch" = true } : {}],
    [{ "key" = "Name", "value" = "jenkins-build-agent", "propagate_at_launch" = true }]
  ])
  enabled_metrics = [
    "GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity",
    "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances",
    "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity",
    "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"
  ]
  # service_linked_role_arn =
}*/
