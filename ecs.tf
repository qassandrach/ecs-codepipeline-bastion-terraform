data "aws_iam_policy_document" "assume_by_ecs" {
    statement {
    sid     = "AllowAssumeByEcsTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }  
}
data "aws_iam_policy_document" "execution-task" {
    statement {
    sid    = "AllowECRLogging"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  
}
data "aws_iam_policy_document" "task-role" {
    statement {
    sid    = "AllowDescribeCluster"
    effect = "Allow"

    actions = ["ecs:DescribeClusters"]

    resources = [aws_ecs_cluster.cluster.arn]
  }
  
}
resource "aws_iam_role" "execution-role" {
    name = "${var.service_name}-ecsTaskExecutionRole"
    assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}
resource "aws_iam_role_policy" "execution-role" {
    role = aws_iam_role.execution-role.name
    policy = data.aws_iam_policy_document.execution-task.json
}
resource "aws_iam_role" "task-role" {
    name = "${var.service_name}-ecsTaskRole"
    assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
  
}
resource "aws_iam_role_policy" "task-role" {
    role = aws_iam_role.task-role.name
    policy = data.aws_iam_policy_document.task-role.json
  
}
resource "aws_ecs_cluster" "cluster" {
    name = "${var.service_name}_cluster"

  
}

resource "aws_security_group" "ecs" {
  name   = "${var.service_name}-allow-ecs"
  vpc_id = aws_vpc.qassie-vpc.id

  ingress {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    cidr_blocks     = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "private"
  }
  
}






