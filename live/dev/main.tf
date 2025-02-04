# AWS CodePIpeline

module "codepipeline" {
  source = "../../modules/services/codepipeline"
  create = var.create_codepipeline

  # Github
  source_repo_id          = var.github_repo_id
  source_repo_branch      = var.github_repo_branch
  codestarconnection_name = var.codestarconnection_name

  # CodeBuild
  codebuild_project_name = module.codebuild.name
  codebuild_arn          = module.codebuild.arn

  # IAM Role
  codepipeline_service_role_arn = module.codepipeline_service_role.role_arn

  # Artifact Bucket
  codepipeline_artifact_bucket = module.codepipeline_artifact_bucket.bucket_arn

  # Tags
  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
