locals {
  name_prefix = lower("${var.custom_tags["Project"] != "" ? var.custom_tags["Project"] : "default-project"}-${var.custom_tags["Environment"] != "" ? var.custom_tags["Environment"] : "default-env"}")
}

resource "aws_codepipeline" "this" {
  count    = var.create ? 1 : 0
  name     = "${local.name_prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline_role[0].arn
  # pipeline_type  = var.pipeline_type
  # execution_mode = var.pipeline_execution_mode

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket[0].bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.encryption_key[0].arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
        ConnectionArn    = try(data.aws_codestarconnections_connection.this[0].arn, null)
        FullRepositoryId = var.source_repo_id
        BranchName       = var.source_repo_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      version          = "1"
      run_order        = 2

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildOutput"]
      # output_artifacts = ["DeployOutput"] # no need for Amazon ECS
      version   = "1"
      run_order = 3

      configuration = {
        ClusterName = var.ecs_cluster
        ServiceName = var.ecs_service
        FileName    = var.image_definition_file_name
        # DeploymentTimeout = var.deployment_timeout
      }
    }
  }

  tags = merge(
    { Name = "${local.name_prefix}-pipeline" },
    var.custom_tags
  )

  depends_on = [data.aws_codestarconnections_connection.this, aws_iam_role.codepipeline_role, aws_s3_bucket.codepipeline_bucket]
}
