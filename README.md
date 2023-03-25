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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_redhat"></a> [redhat](#module\_redhat) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_ubuntu"></a> [ubuntu](#module\_ubuntu) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | >= v3.19.0 |

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
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.jenkins_agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_version"></a> [ansible\_version](#input\_ansible\_version) | version of the playbook that would be run againt the agent | `string` | `"tags/3.7.10"` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | desired capacity for for jenkins agents | `number` | `2` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | maximum capacity for for jenkins agents | `number` | `4` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | minimum capacity for for jenkins agents | `number` | `2` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to which this resources would be created | `string` | `"us-east-1"` | no |
| <a name="input_component"></a> [component](#input\_component) | (optional) describe your variable | `string` | `"devops"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | Metrics that would be monitored by cloudwatch | `list(any)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the instance to launch | `string` | `"t3.micro"` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | n/a | `string` | `"/Users/kojibello/.ssh/id_rsa"` | no |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | n/a | `string` | `"/Users/kojibello/.ssh/id_rsa.pub"` | no |

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
