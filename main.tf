
data "terraform_remote_state" "operational_environment" {
  backend = "s3"

  config = {
    region = "us-east-1"
    bucket = "operational.vpc.kojitechs"
    key    = format("env:/%s/path/env", terraform.workspace)
  }
}

locals {
  operational_state = data.terraform_remote_state.operational_environment.outputs
  vpc_id            = local.operational_state.vpc_id
  public_subnet     = local.operational_state.public_subnets
  private_subnets   = local.operational_state.private_subnets
  github_token      = jsondecode(local.operational_state.secrets_version["githubtoken"])["githubtoken"]
  hostname_prefix   = "${var.environment_purpose_code_map[var.environment_purpose]}atlc2o${var.environment_code_map_name[terraform.workspace]}${format("%02d", var.environment_number)}a"

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


module "required_tags" {
  source = "git::https://github.com/Bkoji1150/kojitechs-tf-aws-required-tags.git?ref=v1.0.0"

  line_of_business        = var.line_of_business
  ado                     = var.ado
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = var.tech_poc_primary
  tech_poc_secondary      = var.builder
  application             = var.application
  builder                 = var.builder
  application_owner       = var.application_owner
  vpc                     = var.vpc
  cell_name               = var.cell_name
  component_name          = var.component_name
}

data "aws_instances" "this" {
  depends_on = [aws_launch_template.registration_app, aws_autoscaling_group.this]

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
  filter {
    name   = "Architecture"
    values = ["x86_64"]
  }
}

module "redhat" {
  count   = 2
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${local.hostname_prefix}${format("%02d", count.index + 1)}redhat"

  ami                    = data.aws_ami.ami["redhat"].id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key.id
  monitoring             = true
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = element(local.public_subnet, count.index)
  user_data = templatefile("./templates/user_data.sh.tpl",
    {
      github_token = local.github_token
      hostname     = "${local.hostname_prefix}${format("%02d", count.index + 1)}redhat"
    }
  )
  tags = merge(module.required_tags.tags, { OS = "redhat" })
}

module "ubuntu" {
  count   = 2
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${local.hostname_prefix}${format("%02d", count.index + 1)}ubuntu"

  ami                    = data.aws_ami.ami["ubuntu"].id
  instance_type          = "t2.xlarge"
  key_name               = aws_key_pair.key.id
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = element(local.public_subnet, count.index)
  user_data = templatefile("./templates/user_data.sh.tpl",
    {
      github_token = local.github_token
      hostname     = "${local.hostname_prefix}${format("%02d", count.index + 1)}redhat"
    }
  )
  tags = merge(module.required_tags.tags, { OS = "ubuntu" })
}


# ################################################################################
# # CREATING  PRIVATE SECURITY GROUP.
# ################################################################################

resource "aws_security_group" "jenkins_sg" {
  name        = "static-sg-${terraform.workspace}"
  description = "Allow inboun from from alb security group id"
  vpc_id      = local.vpc_id

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

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = var.component_name

  provisioner "local-exec" {
    command = "sleep 10"
  }
}


resource "aws_autoscaling_group" "this" {

  desired_capacity  = 2
  health_check_type = "EC2"
  max_size          = 10
  min_size          = 2

  name                    = "${var.component_name}-auto-scalling"
  service_linked_role_arn = aws_iam_service_linked_role.autoscaling.arn

  vpc_zone_identifier = local.public_subnet

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
    value               = var.component_name
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "registration_app" {

  name          = "${local.hostname_prefix}auto-scalling-group"
  description   = "This  Launch template hold configuration for registration app"
  image_id      = data.aws_ami.ami["redhat-8"].id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key.id
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # user_data = base64encode(
  #   templatefile(
  #     "./templates/user_data.sh.tpl",
  #     {
  #     github_token  = local.github_token
  #     hostname = "${local.hostname_prefix}${format("%02d", count.index + 1)}auto-scaling" 
  #   }
  #   )
  # )
  ebs_optimized = true

  update_default_version = true
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 20
      delete_on_termination = true
      volume_type           = "gp3"
    }
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags          = merge(module.required_tags.tags, { OS = "amazon-ec2", Name = "${var.component_name}launch-template" })

  }
  lifecycle {
    create_before_destroy = true
  }
}
