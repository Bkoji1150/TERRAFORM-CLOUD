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
  default     = 4
}

variable "asg_min_size" {
  description = "minimum capacity for for jenkins agents"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "desired capacity for for jenkins agents"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = "t3.xlarge"
}

variable "ansible_version" {
  description = "version of the playbook that would be run againt the agent"
  default     = "tags/3.7.10"
}

variable "enabled_metrics" {
  type        = list(any)
  description = "Metrics that would be monitored by cloudwatch"
}

variable "public_key_path" {
  type    = string
  default = "/Users/kojibello/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  type    = string
  default = "/Users/kojibello/.ssh/id_rsa"
}


# tags variables 
variable "line_of_business" {
  description = "HIDS LOB that owns the resource."
  type        = string
  default     = "TECH"
}

variable "ado" {
  description = "HIDS ADO that owns the resource. The ServiceNow Contracts table is the system of record for the actual ADO names and LOB names."
  type        = string
  default     = "Kojitechs"
}

variable "tier" {
  description = "Network tier or layer where the resource resides. These tiers are represented in every VPC regardless of single-tenant or multi-tenant. For most resources in the Infrastructure and Security VPC, the TIER will be Management. But in some cases,such as Atlassian, the other tiers are relevant."
  type        = string
  default     = "APP"
}

variable "tech_poc_primary" {
  description = "Email Address of the Primary Technical Contact for the AWS resource."
  type        = string
  default     = "kojitechs@gmail.com"
}

variable "tech_poc_secondary" {
  description = "Email Address of the Secondary Technical Contact for the AWS resource."
  type        = string
  default     = "kojitechs@gmail.com"
}

variable "application" {
  description = "Logical name for the application. Mainly used for kojitechs. For an ADO/LOB owned application default to the LOB name."
  type        = string
  default     = "kubernetes"
}

variable "builder" {
  description = "The name of the person who created the resource."
  type        = string
  default     = "kojitechs@gmail.com"
}

variable "application_owner" {
  description = "Email Address of the group who owns the application. This should be a distribution list and no an individual email if at all possible. Primarily used for Ventech-owned applications to indicate what group/department is responsible for the application using this resource. For an ADO/LOB owned application default to the LOB name."
  default     = "kojitechs@gmail.com"
}

variable "vpc" {
  description = "The VPC the resource resides in. We need this to differentiate from Lifecycle Environment due to INFRA and SEC. One of \"APP\", \"INFRA\", \"SEC\", \"ROUTING\"."
  type        = string
  default     = "APP"
}

variable "cell_name" {
  description = "The name of the cell."
  type        = string
  default     = "TECH-GLOBAL"
}

variable "component_name" {
  description = "The name of the component, if applicable."
  type        = string
  default     = "ansible-dynamic-inventory"
}

variable "environment_purpose_code_map" {
  type        = map(string)
  description = "(optional) describe your variable"
  default = {
    primary = "p"
    dr      = "d"
  }
}

variable "environment_purpose" {
  type        = string
  description = "(optional) describe your variable"
  default     = "primary"
}

variable "environment_code_map_name" {
  type        = map(string)
  description = "(optional) describe your variable"
  default = {
    dev  = "d"
    sbx  = "s"
    prod = "p"
  }
}

variable "environment_number" {
  type        = number
  description = "(optional) describe your variable"
  default     = 1
}
