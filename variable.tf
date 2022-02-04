################################################################################
# Autoscaling group
################################################################################

variable "aws_region" {
  default     = "us-east-1"
  description = "Region to which this resources would be created"
}

variable "asg_max_size" {
  description = "maximum capacity for for jenkins agents"
  type        = number
  default     = 3
}

variable "asg_min_size" {
  description = "minimum capacity for for jenkins agents"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "desired capacity for for jenkins agents"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = "t3.micro"
}

variable "ansible_version" {
  description = "version of the playbook that would be run againt the agent"
  default     = "tags/v3.7.10"
}

variable "enabled_metrics" {
  type        = list(any)
  description = "Metrics that would be monitored by cloudwatch"
}
