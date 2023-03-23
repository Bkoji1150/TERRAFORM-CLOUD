
resource "aws_iam_role" "ssm_fleet_instance" {
  name = "fleet-instance-${var.component}"
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
      },
    ]
  })
}

resource "aws_iam_policy" "policy" {
  name        = "baston-policy-${var.component}"
  description = "allow ec2 instance to be managed by ssm"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
        "kms:DescribeKey",
        "ssm:GetParameters",
        "ec2:CreateTags", 
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeAddresses", 
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress",
        "ec2:DescribeRegions",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }   
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ssm_fleet_instance.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ssm-fleet-profile-${terraform.workspace}"
  role = aws_iam_role.ssm_fleet_instance.name
}
