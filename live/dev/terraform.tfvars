#================================
# Global
#================================
project_name       = "dhan-cicd"
environment        = "dev"
aws_region         = "us-east-2"
availability_zones = ["us-east-2a", "us-east-2b"]

#================================
# CodeBuild
#================================
create_codebuild      = true
codebuild_name        = "codebuild"
codebuild_description = "This is codebuild."

// For testing, set build_output_artifact_type = "NO_ARTIFACTS" and build_project_source_type = "NO_SOURCE"
// For production, set build_output_artifact_type = "CODEPIPELINE" and build_project_source_type = "CODEPIPELINE"

# Artifact
codebuild_build_output_artifact_type = "NO_ARTIFACTS"

# source
codebuild_build_project_source_type = "NO_SOURCE"

codebuild_buildspec_file_location = "buildspec.yml" # file from the codecommit repo.

# Environment
codebuild_compute_type                = "BUILD_GENERAL1_SMALL"
codebuild_image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
codebuild_type                        = "LINUX_CONTAINER"
codebuild_image_pull_credentials_type = "CODEBUILD"
codebuild_privileged_mode             = false


#================================
# CodePipeline
#================================
create_codepipeline     = false
github_repo_id          = "dhan-cloudtech/nodejs-apps-multi"
github_repo_branch      = "main"
codestarconnection_name = "dhan-github"
