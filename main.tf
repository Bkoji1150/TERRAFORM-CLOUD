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
  amis = {
    ubuntu = {
      ami_name = "ubuntu/images/hvm-ssd/ubuntu-jammy-*"
    }
    ec2-ami = {
      ami_name = "amzn2-ami-kernel-5.10-hvm-*"
    }
    redhat = {
      ami_name = "RHEL-9.0.0_HVM-*"
    }
    redhat-8 = {
      ami_name = "RHEL_8.6-x86_64-SQL_2022_Standard-*"
    }
  }
}

data "aws_instances" "this" {

  filter {
    name   = "tag:Name"
    values = ["devops-app1-launch-template"]
  }
  filter {
    name   = "tag:OS"
    values = ["amazon-ec2"]
  }

  instance_state_names = ["running"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami" {
  for_each = local.amis

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [each.value.ami_name]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version = ">= v3.19.0"
  name    = "module-vpc-${var.component}"
  cidr    = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = slice([for i in range(1, 225, 2) : cidrsubnet("10.0.0.0/16", 8, i)], 0, 3)
  public_subnets  = slice([for i in range(0, 225, 2) : cidrsubnet("10.0.0.0/16", 8, i)], 0, 3)

  enable_nat_gateway = true # variable(bool)
  enable_vpn_gateway = true # variable(bool)
}

module "redhat" {
  count   = 2
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "redhat-${count.index + 1}"

  ami                    = data.aws_ami.ami["redhat"].id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key.id
  monitoring             = true
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = element(module.vpc.public_subnets, count.index)
  user_data = templatefile("./templates/user_data.sh.tpl",
    {
      ansible_version  = var.ansible_version,
      cwa_config_param = aws_ssm_parameter.cloudwatch_agent.name
    }
  )

  tags = {
    OS = "redhat"
  }
}

module "ubuntu" {
  count   = 2
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "ubuntu-${count.index + 1}"

  ami                    = data.aws_ami.ami["ubuntu"].id
  instance_type          = "t2.xlarge"
  key_name               = aws_key_pair.key.id
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = element(module.vpc.public_subnets, count.index)

  tags = {
    OS = "ubuntu"
  }
}


################################################################################
# CREATING  PRIVATE SECURITY GROUP.
################################################################################

resource "aws_security_group" "jenkins_sg" {
  name        = "static-sg-${terraform.workspace}"
  description = "Allow inboun from from alb security group id"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "allow inboun from from private host mechine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.135.155.78/32"]
  }
  ingress {
    description = "allow inboun from from jenkins server"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["73.135.155.78/32"]
  }
  egress {
    description = "allow egress inb out traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["73.135.155.78/32"]
  }
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
  value       = file("templates/cloudwatch-config.json")
}

resource "aws_ssm_parameter" "ssh_key" {
  depends_on = [aws_key_pair.key]

  name        = "jenkins-agent-bootstrap-ssh-key"
  description = "Value for the jenkins agents ssh key"
  type        = "String"
  tier        = "Standard"
  data_type   = "text"
  value       = file(var.private_key_path)
}

##############################
# CREATING LAUNCH_TEMPLATE
##############################
# resource "aws_launch_template" "app1_lauch_template" {

#   name                   = "${var.component}-app1-launch-template"
#   description            = "This is a template for the application"
#   vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
#   image_id               = data.aws_ami.ami["ec2-ami"].id
#   instance_type          = var.instance_type

#   key_name = aws_key_pair.key.id
#   iam_instance_profile {

#     arn = aws_iam_instance_profile.instance_profile.arn
#   }
#   block_device_mappings {
#     device_name = "/dev/sda1"
#     ebs {
#       volume_size           = 20
#       delete_on_termination = true
#       volume_type           = "gp2"
#     }
#   }

#   user_data = base64encode(
#     templatefile(
#       "./templates/user_data.sh.tpl",
#       {
#         ansible_version  = var.ansible_version,
#         cwa_config_param = aws_ssm_parameter.cloudwatch_agent.name
#       }
#     )
#   )
#   credit_specification {
#     cpu_credits = "standard"
#   }
#   ebs_optimized = true
#   instance_market_options {
#     market_type = "spot"
#   }
#   monitoring {
#     enabled = true
#   }
#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "${var.component}-app1-launch-template"
#       OS   = "amazon-ec2"
#     }
#   }
# }

# resource "aws_autoscaling_group" "app1_asg" {

#   name             = "${var.component}-jenkin-asg"
#   desired_capacity = 2
#   max_size         = 8
#   min_size         = 2

#   vpc_zone_identifier = module.vpc.public_subnets
#   health_check_type   = "EC2"
#   #target_group_arns = [aws_lb_target_group.app1.arn]

#   launch_template {
#     id      = aws_launch_template.app1_lauch_template.id
#     version = aws_launch_template.app1_lauch_template.latest_version
#   }

#   initial_lifecycle_hook {
#     default_result       = "CONTINUE"
#     heartbeat_timeout    = 60
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
#     name                 = "ExampleStartupLifeCycleHook"
#     notification_metadata = jsonencode(
#       {
#         hello = "world"
#       }
#     )
#   }
#   initial_lifecycle_hook {
#     default_result       = "CONTINUE"
#     heartbeat_timeout    = 180
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
#     name                 = "ExampleTerminationLifeCycleHook"
#     notification_metadata = jsonencode(
#       {
#         hello = "world"
#       }
#     )
#   }

#   tag {
#     key                 = "component"
#     value               = var.component
#     propagate_at_launch = true
#   }

#   instance_refresh {
#     strategy = "Rolling"                               # UPDATE 
#     triggers = ["tag", "desired_capacity", "max_size"] # 

#     preferences {
#       min_healthy_percentage = 50
#     }
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
#   enabled_metrics = var.enabled_metrics
# }
resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = var.component

  provisioner "local-exec" {
    command = "sleep 10"
  }
}


resource "aws_autoscaling_group" "this" {

  desired_capacity  = 4
  health_check_type = "EC2"
  max_size          = 10
  min_size          = 4

  name                    = "${var.component}-auto-scalling"
  service_linked_role_arn = aws_iam_service_linked_role.autoscaling.arn

  vpc_zone_identifier = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.registration_app.id
    version = aws_launch_template.registration_app.latest_version
  }
  initial_lifecycle_hook {
    default_result       = "CONTINUE"
    heartbeat_timeout    = 180
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
    name                 = "ExampleTerminationLifeCycleHook"
    notification_metadata = jsonencode(
      {
        goodbye = "world"
      }
    )
  }
  initial_lifecycle_hook {
    default_result       = "CONTINUE"
    heartbeat_timeout    = 60
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    name                 = "ExampleStartupLifeCycleHook"
    notification_metadata = jsonencode(
      {
        hello = "world"
      }
    )
  }
  instance_refresh {
    strategy = "Rolling"
    triggers = [
      "desired_capacity",
      "tag", "max_size",
    ]

    preferences {
      min_healthy_percentage = 50
      skip_matching          = false
    }
  }

  timeouts {}
  tag {
    key                 = "component"
    value               = var.component
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "registration_app" {

  name          = format("%s-%s", var.component, "auto-scalling-group")
  description   = "This  Launch template hold configuration for registration app"
  image_id      = data.aws_ami.ami["ec2-ami"].id
  instance_type = var.instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = base64encode(
    templatefile(
      "./templates/user_data.sh.tpl",
      {
        ansible_version  = var.ansible_version,
        cwa_config_param = aws_ssm_parameter.cloudwatch_agent.name
      }
    )
  )
  ebs_optimized = true

  update_default_version = true
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 20
      delete_on_termination = true
      volume_type           = "gp2"
    }
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.component}-app1-launch-template"
      OS   = "amazon-ec2"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
