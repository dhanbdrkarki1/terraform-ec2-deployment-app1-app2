#================================
# CodeDeploy Service Role
#================================
module "codedeploy_service_role" {
  source           = "../../modules/services/iam"
  create           = true
  role_name        = "CodeDeployServiceRole"
  role_description = "IAM role for CodeDeploy"

  # Trust relationship policy for CodeDeploy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # CodeDeploy permissions policy
  role_policies = {
    S3FullAccess  = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    CodedeployEC2 = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  }

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



#================================
# CodeDeploy 
#================================
