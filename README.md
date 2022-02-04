# AWS Auto Scaling Group (ASG) Terraform module for HQR

Terraform module which creates Auto Scaling resources on AWS.

Available features

- Autoscaling group with launch configuration - either created by the module or utilizing an existing launch configuration
- Autoscaling group with launch template - either created by the module or utilizing an existing launch template
- Autoscaling group utilizing mixed instances policy
- Ability to configure autoscaling groups to set instance refresh configuration and add lifecycle hooks
- Ability to configure autoscaling policies


## Conditional creation

The following combinations are supported to conditionally create resources and/or use externally created resources within the module:

- Disable resource creation (no resources created):

```hcl
  create_asg = false
```

- Create only a launch configuration:

```hcl
  create_asg = false
  create_lc  = true
```

- Create only a launch template:

```hcl
  create_asg = false
  create_lt  = true
```

- Create both the autoscaling group and launch configuration:

```hcl
  use_lc    = true
  create_lc = true
```

- Create both the autoscaling group and launch template:

```hcl
  use_lt    = true
  create_lt = true
```

- Create the autoscaling group using an externally created launch configuration:

```hcl
  use_lc               = true
  launch_configuration = aws_launch_configuration.my_launch_config.name
```

- Create the autoscaling group using an externally created launch template:

```hcl
  use_lt          = true
  launch_template = aws_launch_template.my_launch_template.name
```

- Create the autoscaling policies:

```
  scaling_policies = {
    my-policy = {
      policy_type               = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
          resource_label         = "MyLabel"
        }
        target_value = 50.0
      }
    }
  }
```

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/examples/complete) - Creates several variations of resources for autoscaling groups, launch templates, launch configurations.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=3, <4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.ec2_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ec2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.ec2_policy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_launch_template.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.jenkins_golden_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.jenkins_agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_version"></a> [ansible\_version](#input\_ansible\_version) | version of the playbook that would be run againt the agent | `string` | `"tags/v3.7.10"` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | desired capacity for for jenkins agents | `number` | `2` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | maximum capacity for for jenkins agents | `number` | `3` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | minimum capacity for for jenkins agents | `number` | `1` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to which this resources would be created | `string` | `"us-east-1"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | Metrics that would be monitored by cloudwatch | `list(any)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the instance to launch | `string` | `"t3.micro"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/LICENSE) for full details.
