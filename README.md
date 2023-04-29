# AWS Auto Scaling Group (ASG) Terraform module for HQR

Terraform module which creates Auto Scaling resources on HQR.

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/examples/complete) - Creates several variations of resources for autoscaling groups, launch templates, launch configurations.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.60.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_redhat"></a> [redhat](#module\_redhat) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_required_tags"></a> [required\_tags](#module\_required\_tags) | git::https://github.com/Bkoji1150/kojitechs-tf-aws-required-tags.git | v1.0.0 |
| <a name="module_ubuntu"></a> [ubuntu](#module\_ubuntu) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ec2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.ec2_policy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_service_linked_role.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_key_pair.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.registration_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.jenkins_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ansible_inventory_private](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.jenkins_agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [terraform_remote_state.operational_environment](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado"></a> [ado](#input\_ado) | HIDS ADO that owns the resource. The ServiceNow Contracts table is the system of record for the actual ADO names and LOB names. | `string` | `"Kojitechs"` | no |
| <a name="input_ansible_version"></a> [ansible\_version](#input\_ansible\_version) | version of the playbook that would be run againt the agent | `string` | `"tags/3.7.10"` | no |
| <a name="input_application"></a> [application](#input\_application) | Logical name for the application. Mainly used for kojitechs. For an ADO/LOB owned application default to the LOB name. | `string` | `"kubernetes"` | no |
| <a name="input_application_owner"></a> [application\_owner](#input\_application\_owner) | Email Address of the group who owns the application. This should be a distribution list and no an individual email if at all possible. Primarily used for Ventech-owned applications to indicate what group/department is responsible for the application using this resource. For an ADO/LOB owned application default to the LOB name. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | desired capacity for for jenkins agents | `number` | `2` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | maximum capacity for for jenkins agents | `number` | `4` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | minimum capacity for for jenkins agents | `number` | `2` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to which this resources would be created | `string` | `"us-east-1"` | no |
| <a name="input_builder"></a> [builder](#input\_builder) | The name of the person who created the resource. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_cell_name"></a> [cell\_name](#input\_cell\_name) | The name of the cell. | `string` | `"TECH-GLOBAL"` | no |
| <a name="input_component_name"></a> [component\_name](#input\_component\_name) | The name of the component, if applicable. | `string` | `"ansible-dynamic-inventory"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | Metrics that would be monitored by cloudwatch | `list(any)` | n/a | yes |
| <a name="input_environment_code_map_name"></a> [environment\_code\_map\_name](#input\_environment\_code\_map\_name) | (optional) describe your variable | `map(string)` | <pre>{<br>  "dev": "d",<br>  "prod": "p",<br>  "sbx": "s"<br>}</pre> | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | (optional) describe your variable | `number` | `1` | no |
| <a name="input_environment_purpose"></a> [environment\_purpose](#input\_environment\_purpose) | (optional) describe your variable | `string` | `"primary"` | no |
| <a name="input_environment_purpose_code_map"></a> [environment\_purpose\_code\_map](#input\_environment\_purpose\_code\_map) | (optional) describe your variable | `map(string)` | <pre>{<br>  "dr": "d",<br>  "primary": "p"<br>}</pre> | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the instance to launch | `string` | `"t3.xlarge"` | no |
| <a name="input_line_of_business"></a> [line\_of\_business](#input\_line\_of\_business) | HIDS LOB that owns the resource. | `string` | `"TECH"` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | n/a | `string` | `"/Users/kojibello/.ssh/id_rsa"` | no |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | n/a | `string` | `"/Users/kojibello/.ssh/id_rsa.pub"` | no |
| <a name="input_tech_poc_primary"></a> [tech\_poc\_primary](#input\_tech\_poc\_primary) | Email Address of the Primary Technical Contact for the AWS resource. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_tech_poc_secondary"></a> [tech\_poc\_secondary](#input\_tech\_poc\_secondary) | Email Address of the Secondary Technical Contact for the AWS resource. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Network tier or layer where the resource resides. These tiers are represented in every VPC regardless of single-tenant or multi-tenant. For most resources in the Infrastructure and Security VPC, the TIER will be Management. But in some cases,such as Atlassian, the other tiers are relevant. | `string` | `"APP"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The VPC the resource resides in. We need this to differentiate from Lifecycle Environment due to INFRA and SEC. One of "APP", "INFRA", "SEC", "ROUTING". | `string` | `"APP"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## ssh to the server
```sh
ssh -i ~/.ssh/id_rsa ec2-user@18.207.186.214

vi /etc/ssh/sshd_config
service sshd reload
visudo
ansible ubuntu -i ./ansible/inventory/hosts --private-key ~/.ssh/id_rsa -u ubuntu -m ping

ansible all -i ./ansible/inventory/host.cfg --private-key ~/.ssh/id_rsa -u ec2-user -m ping
```
## Authors

Module is maintained by [kOJI BELLO](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/graphs/contributors).
