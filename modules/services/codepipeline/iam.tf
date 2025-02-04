# #Code Pipeline
# resource "aws_iam_role" "codepipeline_role" {
#   count              = var.create ? 1 : 0
#   name               = "${local.name_prefix}-pipeline-role"
#   tags               = var.custom_tags
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "codepipeline.amazonaws.com"
#       },
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
#   path               = "/"
# }

# # resource "aws_iam_policy" "codepipeline_policy" {
# #   count       = var.create ? 1 : 0
# #   name        = "${local.name_prefix}-codepipeline-policy"
# #   description = "Policy to allow codepipeline to execute"
# #   tags        = var.custom_tags
# #   policy      = <<EOF
# # {
# #   "Version": "2012-10-17",
# #   "Statement": [
# #     {
# #       "Effect":"Allow",
# #       "Action": [
# #         "s3:GetObject",
# #         "s3:GetObjectVersion",
# #         "s3:GetBucketVersioning",
# #         "s3:PutObjectAcl",
# #         "s3:PutObject",
# #         "s3:ListBucket",
# #         "s3:GetBucketAcl",
# #         "s3:GetBucketLocation",
# #         "s3:DeleteObject"
# #       ],
# #       "Resource": [
# #         "${aws_s3_bucket.codepipeline_bucket[0].arn}",
# #         "${aws_s3_bucket.codepipeline_bucket[0].arn}/*"
# #       ]
# #     },
# #     {
# #       "Effect": "Allow",
# #       "Action": [
# #          "kms:DescribeKey",
# #          "kms:GenerateDataKey*",
# #          "kms:Encrypt",
# #          "kms:ReEncrypt*",
# #          "kms:Decrypt"
# #       ],
# #       "Resource": "${aws_kms_key.encryption_key[0].arn}"
# #     },
# #     {
# #       "Effect": "Allow",
# #       "Action": [
# #          "codecommit:GetBranch",
# #          "codecommit:GetCommit",
# #          "codecommit:GetUploadArchiveStatus",
# #          "codecommit:CancelUploadArchive",
# #          "codecommit:GitPull",
# #          "codecommit:GitPush",
# #          "codecommit:CreateCommit",
# #          "codecommit:ListRepositories",
# #          "codecommit:BatchGetCommits",
# #          "codecommit:BatchGetRepositories",
# #          "codecommit:GetRepository",
# #          "codecommit:ListBranches",
# #          "codecommit:UploadArchive"
# #       ],
# #       "Resource": "*"
# #     },
# #     {
# #       "Effect": "Allow",
# #       "Action": [
# #         "codebuild:BatchGetBuilds",
# #         "codebuild:StartBuild",
# #         "codebuild:BatchGetProjects"
# #       ],
# #       "Resource": "${var.codebuild_arn}"
# #     },
# #     {
# #       "Effect": "Allow",
# #       "Action": [
# #         "codebuild:CreateReportGroup",
# #         "codebuild:CreateReport",
# #         "codebuild:UpdateReport",
# #         "codebuild:BatchPutTestCases"
# #       ],
# #       "Resource": "*"
# #     },
# #     {
# #       "Effect": "Allow",
# #       "Action": [
# #         "logs:CreateLogGroup",
# #         "logs:CreateLogStream",
# #         "logs:PutLogEvents"
# #       ],
# #       "Resource": "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
# #     }
# #   ]
# # }
# # EOF
# # }

# resource "aws_iam_policy" "codepipeline_policy" {
#   count       = var.create ? 1 : 0
#   name        = "${local.name_prefix}-codepipeline-policy"
#   description = "Policy to allow codepipeline to execute"
#   tags        = var.custom_tags
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "iam:PassRole"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#         Condition = {
#           StringEqualsIfExists = {
#             "iam:PassedToService" = [
#               "cloudformation.amazonaws.com",
#               "elasticbeanstalk.amazonaws.com",
#               "ec2.amazonaws.com",
#               "ecs-tasks.amazonaws.com"
#             ]
#           }
#         }
#       },
#       {
#         Action = [
#           "codecommit:CancelUploadArchive",
#           "codecommit:GetBranch",
#           "codecommit:GetCommit",
#           "codecommit:GetRepository",
#           "codecommit:GetUploadArchiveStatus",
#           "codecommit:UploadArchive"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:GetBucketVersioning",
#           "s3:PutObjectAcl",
#           "s3:PutObject",
#           "s3:ListBucket",
#           "s3:GetBucketAcl",
#           "s3:GetBucketLocation",
#           "s3:DeleteObject"
#         ]
#         Resource = [
#           "${aws_s3_bucket.codepipeline_bucket[0].arn}",
#           "${aws_s3_bucket.codepipeline_bucket[0].arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:DescribeKey",
#           "kms:GenerateDataKey*",
#           "kms:Encrypt",
#           "kms:ReEncrypt*",
#           "kms:Decrypt"
#         ]
#         Resource = "${aws_kms_key.encryption_key[0].arn}"
#       },
#       {
#         Action = [
#           "codedeploy:CreateDeployment",
#           "codedeploy:GetApplication",
#           "codedeploy:GetApplicationRevision",
#           "codedeploy:GetDeployment",
#           "codedeploy:GetDeploymentConfig",
#           "codedeploy:RegisterApplicationRevision"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Action = [
#           "codestar-connections:UseConnection"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Action = [
#           "elasticbeanstalk:*",
#           "ec2:*",
#           "elasticloadbalancing:*",
#           "autoscaling:*",
#           "cloudwatch:*",
#           "sns:*",
#           "cloudformation:*",
#           "rds:*",
#           "sqs:*",
#           "ecs:*"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Action = [
#           "lambda:InvokeFunction",
#           "lambda:ListFunctions"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Action = [
#           "opsworks:CreateDeployment",
#           "opsworks:DescribeApps",
#           "opsworks:DescribeCommands",
#           "opsworks:DescribeDeployments",
#           "opsworks:DescribeInstances",
#           "opsworks:DescribeStacks",
#           "opsworks:UpdateApp",
#           "opsworks:UpdateStack"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Action = [
#           "cloudformation:CreateStack",
#           "cloudformation:DeleteStack",
#           "cloudformation:DescribeStacks",
#           "cloudformation:UpdateStack",
#           "cloudformation:CreateChangeSet",
#           "cloudformation:DeleteChangeSet",
#           "cloudformation:DescribeChangeSet",
#           "cloudformation:ExecuteChangeSet",
#           "cloudformation:SetStackPolicy",
#           "cloudformation:ValidateTemplate"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Action = [
#           "codebuild:BatchGetBuilds",
#           "codebuild:StartBuild",
#           "codebuild:BatchGetBuildBatches",
#           "codebuild:StartBuildBatch"
#         ]
#         Resource = "*"
#         Effect   = "Allow"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "devicefarm:ListProjects",
#           "devicefarm:ListDevicePools",
#           "devicefarm:GetRun",
#           "devicefarm:GetUpload",
#           "devicefarm:CreateUpload",
#           "devicefarm:ScheduleRun"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "servicecatalog:ListProvisioningArtifacts",
#           "servicecatalog:CreateProvisioningArtifact",
#           "servicecatalog:DescribeProvisioningArtifact",
#           "servicecatalog:DeleteProvisioningArtifact",
#           "servicecatalog:UpdateProduct"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "cloudformation:ValidateTemplate"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ecr:DescribeImages"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "states:DescribeExecution",
#           "states:DescribeStateMachine",
#           "states:StartExecution"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "appconfig:StartDeployment",
#           "appconfig:StopDeployment",
#           "appconfig:GetDeployment"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }


# resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
#   count      = var.create ? 1 : 0
#   role       = aws_iam_role.codepipeline_role[0].name
#   policy_arn = aws_iam_policy.codepipeline_policy[0].arn
# }

