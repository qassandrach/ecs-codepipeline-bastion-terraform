data "aws_ami" "latest-ecs" {
    most_recent = true
    owners = ["591542846629"]

    filter {
        name = "name"
        values = ["amzn2-ami-ecs-hvm-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
resource "aws_launch_configuration" "aws-launch" {
    name = "ECS-Instance-${var.service_name}"
    instance_type = "c5.large"
    image_id             = data.aws_ami.latest-ecs.id
    iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id

    root_block_device {
        volume_type = "standard"
        volume_size = 30
        delete_on_termination = true
    }
    lifecycle {
        create_before_destroy = true
    }
    security_groups = ["${aws_security_group.ecs.id}"]
    associate_public_ip_address = "false"
    key_name = aws_key_pair.bastion.key_name
    user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.service_name}_cluster >> /etc/ecs/ecs.config
    EOF
  
}
resource "aws_autoscaling_group" "ec2-autoscaling" {
    name = "${var.service_name}-ecs-autoscaling-group"
    max_size = 2
    min_size = 1
    desired_capacity = 1
    vpc_zone_identifier = [aws_subnet.private-sub-1.id,aws_subnet.private-sub-2.id]
    launch_configuration = aws_launch_configuration.aws-launch.name
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "ECS-Instance-${var.service_name}-service"
        propagate_at_launch = true

    }
  
}
resource "aws_iam_role" "ecs_instance_role" {
    name = "${var.service_name}-ecs-instance-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
  
}
data "aws_iam_policy_document" "ecs-instance-policy" {
    statement{
        actions = ["sts:AssumeRole"]
        principals {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
        }
    }
}
resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role = "${aws_iam_role.ecs_instance_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  
}
resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "${var.service_name}-ecs-instance-profile"
    path = "/"
    role = "${aws_iam_role.ecs_instance_role.id}" 
}



