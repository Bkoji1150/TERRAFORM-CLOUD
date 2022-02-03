################################################################################
# Autoscaling group
################################################################################

variable "aws_region" {
  default     = "us-east-1"
  description = "Region to which this resources would be created"
}


variable "asg_max_size" {
  description = "Indicates whether capacity rebalance is enabled"
  type        = number
  default     = 3
}

variable "asg_min_size" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior."
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "(LC) The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument nor when using Launch Templates; see `user_data_base64` instead"
  type        = string
  default     = null
}

variable "public_key_path" {
  type        = string
  description = "local keypair"
  default     = "/Users/kojibello/.ssh/id_rsa.pub"
}

variable "ami" {
  type        = string
  sensitive   = true
  description = "ami id specific only to for jenkins/sonarqube build in us-east-1"
  default     = "ami-0a8b4cd432b1c3063"
}
