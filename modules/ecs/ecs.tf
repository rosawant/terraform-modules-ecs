resource "aws_iam_role" "ecsContainerInstaceIAMRole" {
  name = "${var.ecs_cluster_name}-ecsContainerInstaceIAMRole"

  assume_role_policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOT

}

locals {
  managed_roles = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
  ]
}

resource "aws_iam_role_policy_attachment" "ec2-role-attach" {
  role = aws_iam_role.ecsContainerInstaceIAMRole.name

  count      = length(local.managed_roles)
  policy_arn = element(local.managed_roles, count.index)
}

resource "aws_iam_instance_profile" "ec2-instance-role" {
  name = "${var.ecs_cluster_name}-ec2-instance-role"
  role = aws_iam_role.ecsContainerInstaceIAMRole.name
}

resource "aws_iam_role_policy" "ECSSQSTaskExecutionPolicy" {
  name = "${var.ecs_cluster_name}-ECSSQSTaskExecutionPolicy"
  role = aws_iam_role.ecsContainerInstaceIAMRole.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "sqs:*",
								"ecr:GetAuthorizationToken",
								"ec2:AssociateAddress",
								"ec2:Describe*",
								"application-autoscaling:DescribeScalableTargets",
								"application-autoscaling:DescribeScalingActivities",
								"application-autoscaling:DescribeScalingPolicies",
								"application-autoscaling:DescribeScheduledActions",
								"application-autoscaling:RegisterScalableTarget",
								"application-autoscaling:PutScalingPolicy",
								"application-autoscaling:PutScheduledAction",
								"sns:*",
								"autoscaling:Describe*",
								"cloudwatch:ListMetrics",
								"cloudwatch:GetMetricStatistics",
								"cloudwatch:PutMetricData",
								"cloudwatch:PutMetricAlarm",
								"cloudwatch:Describe*",
								"kms:Decrypt",
								"kms:DescribeKey",
								"kms:Encrypt",
								"kms:ListKeys",
								"kms:ListAliases",
								"kms:DescribeKey",
								"kms:ListKeyPolicies",
								"kms:GetKeyPolicy",
								"kms:GetKeyRotationStatus"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_ecs_cluster" "main" {
  name = "${var.Environment}${var.ecs_cluster_name}"
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    ecs_config   = var.ecs_config
    cluster_name = aws_ecs_cluster.main.name
  }
}

resource "aws_security_group" "instance_sg" {
  name_prefix   = "allow port"
  vpc_id = var.VpcId

  ingress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = "tcp"
    cidr_blocks = [var.InboundCIDRBlock]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_launch_configuration" "ManagementLaunchConfig" {
  name_prefix                 = "${var.ecs_cluster_name}-ManagementLaunchConfig"
  image_id                    = data.aws_ami.amazon_linux_ecs.id
  instance_type               = var.InstanceType
  security_groups             = [aws_security_group.instance_sg.id]
  user_data                   = data.template_file.user_data.rendered
  iam_instance_profile        = aws_iam_instance_profile.ec2-instance-role.name
  associate_public_ip_address = false
  ebs_optimized               = false
  enable_monitoring           = false
  key_name                    = var.EC2KeyPair != "" ? var.EC2KeyPair : ""

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ManagementEC2Instance" {
  name_prefix                      = "${var.Environment}-${var.ecs_cluster_name}"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  default_cooldown          = 120
  health_check_grace_period = 180
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.ManagementLaunchConfig.id
  vpc_zone_identifier       = var.private_subnet_ids
}


output "autoscaling_group" {
  value = aws_autoscaling_group.ManagementEC2Instance.name
}

resource "aws_cloudwatch_log_group" "ecs_loggroup" {
  name_prefix = "${var.Environment}-${var.ecs_cluster_name}-logs"

  tags = {
    Environment = var.Environment
  }
}
