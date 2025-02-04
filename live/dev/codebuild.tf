#================================
# CodeBuild Service Role
#================================
module "codebuild_service_role" {
  source           = "../../modules/services/iam"
  create           = true
  role_name        = "CodeBuildServiceRole"
  role_description = "IAM role for CodeBuild"

  # Trust relationship policy for CodeBuild
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # CodeBuild permissions policy
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 permissions
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          module.codebuild_artifact_bucket.bucket_arn,
          "${module.codebuild_artifact_bucket.bucket_arn}/*"
        ]
      },
      # CloudWatch Logs permissions
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # CodeBuild permissions
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "*" # All resources
      },
      # CodeStart and CodeConnection Permssions
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:GetConnectionToken",
          "codestar-connections:GetConnection",
          "codeconnections:GetConnectionToken",
          "codeconnections:GetConnection",
          "codeconnections:UseConnection"
        ]
        # updte codestart connection arn and codeconnection arn
        Resource = "*"
      }
    ]
  })

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "codebuild_artifact_bucket" {
  source               = "../../modules/services/s3"
  create               = true
  bucket_name          = "codebuild-logs"
  enable_versioning    = true
  force_destroy        = true
  create_bucket_policy = true
  bucket_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "${module.codebuild_artifact_bucket.bucket_arn}",
          "${module.codebuild_artifact_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

  custom_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "codebuild_log_group" {
  source            = "../../modules/services/cloudwatch"
  create            = true
  name              = "/aws/codebuild/${var.project_name}-${var.environment}"
  retention_in_days = 30

  custom_tags = {
    Name        = "/aws/codebuild/${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}


module "codebuild" {
  source      = "../../modules/services/codebuild"
  create      = var.create_codebuild
  name        = var.codebuild_name
  description = var.codebuild_description

  # IAM Role
  codebuild_service_role_arn = module.codebuild_service_role.role_arn

  # Artifact Bucket
  bucket_name = module.codebuild_artifact_bucket.bucket_name
  bucket_id   = module.codebuild_artifact_bucket.bucket_id

  # Log group
  codebuild_log_group_name = module.codebuild_log_group.log_group_name


  // For testing, set build_output_artifact_type = "NO_ARTIFACTS", build_project_source_type = "NO_SOURCE" and comment source_location.
  // For production, set build_output_artifact_type = "CODEPIPELINE" and build_project_source_type = "CODEPIPELINE"

  # Artifact
  build_output_artifact_type = var.codebuild_build_output_artifact_type

  # source

  build_project_source_type = "GITHUB"
  buildspec_file_location   = "buildspec.yml"
  source_location           = "https://github.com/dhan-cloudtech/nodejs-apps-multi.git"
  git_clone_depth           = 1
  report_build_status       = true
  fetch_submodules          = true

  build_status_config = {
    context    = "continuous-integration/codebuild"
    target_url = "https://console.aws.amazon.com/codebuild/home"
  }

  # Environment
  compute_type                = var.codebuild_compute_type
  image                       = var.codebuild_image
  type                        = var.codebuild_type
  image_pull_credentials_type = var.codebuild_image_pull_credentials_type
  privileged_mode             = var.codebuild_privileged_mode
  # environment_variables = [
  #   # ECR Repo
  #   {
  #     name  = "REPOSITORY_URI"
  #     value = module.ecr.repository_url
  #     type  = "PLAINTEXT"
  #   },
  #   {
  #     name  = "AWS_DEFAULT_REGION"
  #     value = "${var.aws_region}"
  #     type  = "PLAINTEXT"
  #   },
  #   {
  #     name  = "AWS_ACCOUNT_ID"
  #     value = "${var.aws_account_id}"
  #     type  = "PLAINTEXT"
  #   }
  # ]

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
