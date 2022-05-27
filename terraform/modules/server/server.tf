module "myvpc" {
  source = "../vpc"
}
resource "aws_security_group" "server_sg" {
  tags = {
    Name = "${var.env}-sg"
  }

  name   = "${var.env}-sg"
  vpc_id = module.myvpc.myvpcid

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_cidr_block}"]

  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

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

  tags = {
    name = "ec2_role"
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_role.id
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "ec2_launchtemplate" {
  name_prefix   = var.aws_region
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = "testkey"
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  user_data     = "IyEvYmluL2Jhc2gKc3VkbyBhcHQtZ2V0IHVwZGF0ZQpzdWRvIGFwdC1pbnN0YWxsIHB5dGhvbjMtcGlwCnN1ZG8gYXB0LWdldCBpbnN0YWxsIFwKICAgIGNhLWNlcnRpZmljYXRlcyBcCiAgICBjdXJsIFwKICAgIGdudXBnIFwKICAgIGxzYi1yZWxlYXNlIC15CmN1cmwgLWZzU0wgaHR0cHM6Ly9kb3dubG9hZC5kb2NrZXIuY29tL2xpbnV4L3VidW50dS9ncGcgfCBzdWRvIGdwZyAtLWRlYXJtb3IgLW8gL3Vzci9zaGFyZS9rZXlyaW5ncy9kb2NrZXItYXJjaGl2ZS1rZXlyaW5nLmdwZwplY2hvIFwKICAiZGViIFthcmNoPSQoZHBrZyAtLXByaW50LWFyY2hpdGVjdHVyZSkgc2lnbmVkLWJ5PS91c3Ivc2hhcmUva2V5cmluZ3MvZG9ja2VyLWFyY2hpdmUta2V5cmluZy5ncGddIGh0dHBzOi8vZG93bmxvYWQuZG9ja2VyLmNvbS9saW51eC91YnVudHUgXAogICQobHNiX3JlbGVhc2UgLWNzKSBzdGFibGUiIHwgc3VkbyB0ZWUgL2V0Yy9hcHQvc291cmNlcy5saXN0LmQvZG9ja2VyLmxpc3QgPiAvZGV2L251bGwKc3VkbyBhcHQtZ2V0IHVwZGF0ZQpzdWRvIGFwdC1nZXQgaW5zdGFsbCBkb2NrZXItY2UgZG9ja2VyLWNlLWNsaSBjb250YWluZXJkLmlvIGRvY2tlci1jb21wb3NlLXBsdWdpbiAteQpzdWRvIHVzZXJtb2QgLWFHIGRvY2tlciAkVVNFUgpzdWRvIGRvY2tlciBydW4gLXAgNTAwMDo1MDAwIC1kIHNoaXZhbXNoZXJrYXIvZmxhc2stY29udGFpbmVyOjIuMAo="
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
  # network_interfaces {
  #   associate_public_ip_address = true
  # }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }
}

resource "aws_autoscaling_group" "ec2_autoscaling" {
  # availability_zones  = [element(var.az, 0), element(var.az, 1)]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = [module.myvpc.publicsubnetid, module.myvpc.publicsubnet1id]
  target_group_arns   = [aws_lb_target_group.alb_targetgroup.arn]
  

  launch_template {
    id      = aws_launch_template.ec2_launchtemplate.id
    version = "$Latest"
  }
}

resource "aws_lb" "ec2_loadbalancer" {
  name               = "${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.server_sg.id]
  subnets            = [module.myvpc.publicsubnetid, module.myvpc.publicsubnet1id]
}

# Add Target Group
resource "aws_lb_target_group" "alb_targetgroup" {
  name     = "alb-targetgroup"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = module.myvpc.myvpcid
  health_check {
    path = "/ec2"
  }
}

# Adding HTTP listener
resource "aws_lb_listener" "webserver_listner" {
  load_balancer_arn = aws_lb.ec2_loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_targetgroup.arn
    type             = "forward"
  }
}

output "load_balancer_output" {
  value = aws_lb.ec2_loadbalancer.dns_name
}



