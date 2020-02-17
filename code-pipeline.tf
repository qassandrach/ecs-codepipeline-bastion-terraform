locals {
    github_token = ""
  github_owner = "qassandrach"
  github_repo = "individual-project"
  github_branch = "master"
}

resource "aws_s3_bucket" "pipeline" {
    bucket = "${var.service_name}-codepipeline-bucket"
    acl = "private"
    force_destroy = true
}
data "aws_iam_policy_document" "assume_by_pipeline" {
    statement {
        sid = "AllowAssumeByPipeline"
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals{
            type = "Service"
            identifiers = ["codepipeline.amazonaws.com"]
        }
    }
  
}
resource "aws_iam_role" "pipeline" {
    name = "${var.service_name}-pipeline-ecs-service-role"
    assume_role_policy = data.aws_iam_policy_document.assume_by_pipeline.json
}
data "aws_iam_policy_document" "pipeline" {
    statement {
        sid = "AllowS3"
        effect = "Allow"

        actions = [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
        ]
        resources = ["*"]
    }
  statement {
      sid = "AllowECR"
      effect = "Allow"

      actions = ["ecr:DescribeImages"]
      resources = ["*"]
  }
  statement {
      sid = "AllowCodebuild"
      effect = "Allow"
      
      actions = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
      ]
      resources = ["*"]

  }
  statement {
      sid = "AllowCodedeploy"
      effect = "Allow"

      actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }
  statement {
      sid = "AllowResources"
      effect = "Allow"

      actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "opsworks:*",
      "devicefarm:*",
      "servicecatalog:*",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
  
}
resource "aws_iam_role_policy" "pipeline" {
    role = "${aws_iam_role.pipeline.name}"
    policy = data.aws_iam_policy_document.pipeline.json
  
}
resource "aws_codepipeline" "pipeline" {
    name = "${var.service_name}-pipeline"
    role_arn = aws_iam_role.pipeline.arn

    artifact_store {
    location = aws_s3_bucket.pipeline.bucket
    type = "S3"
    }
    stage {
        name = "Source"
        action {
            name = "Source"
            category = "Source"
            owner = "ThirdParty"
            provider = "GitHub"
            version = "1"
            output_artifacts = ["SourceArtifact"]

            configuration = {
                OAuthToken = local.github_token
                Owner = local.github_owner
                Repo = local.github_repo
                Branch = local.github_branch
            }
        }
    }
    stage {
      name = "Build"

      action {
        name = "Build"
        category = "Build"
        owner = "AWS"
        provider = "CodeBuild"
        version = "1"
        input_artifacts = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]

        configuration = {
            ProjectName = aws_codebuild_project.build.name
        }
      }
    }
    stage {
        name = "Deploy"

        action {
            name = "ExternalDeploy"
            category = "Deploy"
            owner = "AWS"
            provider = "ECS"
            input_artifacts = ["BuildArtifact"]
            version = "1"

            configuration = {
                ClusterName = "${var.service_name}_cluster"
                ServiceName = var.service_name
                FileName = "taskdef.json"
            }
        }
    }   
  
}








  

