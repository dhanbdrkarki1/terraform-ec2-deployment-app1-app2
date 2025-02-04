# # KMS
# locals {
#   account_id = data.aws_caller_identity.current.account_id
# }

# resource "aws_kms_key" "encryption_key" {
#   count                   = var.create ? 1 : 0
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 30
#   key_usage               = "ENCRYPT_DECRYPT"
#   policy                  = data.aws_iam_policy_document.kms_key_policy_doc[0].json
#   is_enabled              = true
#   enable_key_rotation     = true
#   tags = merge(
#     { Name = "${local.name_prefix}" },
#     var.custom_tags
#   )
# }

# data "aws_iam_policy_document" "kms_key_policy_doc" {
#   count = var.create ? 1 : 0
#   statement {
#     sid     = "Enable IAM User Permissions"
#     effect  = "Allow"
#     actions = ["kms:*"]
#     #checkov:skip=CKV_AWS_109:Without this statement, KMS key cannot be managed by root
#     resources = ["*"]

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${local.account_id}:root"]
#     }
#   }


#   # statement {
#   #   sid       = "Allow access for Key Administrators"
#   #   effect    = "Allow"
#   #   actions   = ["kms:*"]
#   #   resources = ["*"]

#   #   principals {
#   #     type = "AWS"
#   #     identifiers = [
#   #       aws_iam_role.codepipeline_role[0].arn
#   #     ]
#   #   }
#   # }

#   # statement {
#   #   sid    = "Allow use of the key"
#   #   effect = "Allow"
#   #   actions = [
#   #     "kms:Encrypt",
#   #     "kms:Decrypt",
#   #     "kms:ReEncrypt*",
#   #     "kms:GenerateDataKey*",
#   #     "kms:DescribeKey"
#   #   ]
#   #   resources = ["*"]

#   #   principals {
#   #     type = "AWS"
#   #     identifiers = [
#   #       aws_iam_role.codepipeline_role[0].arn
#   #     ]
#   #   }
#   # }

#   # statement {
#   #   sid    = "Allow attachment of persistent resources"
#   #   effect = "Allow"
#   #   actions = [
#   #     "kms:CreateGrant",
#   #     "kms:ListGrants",
#   #     "kms:RevokeGrant"
#   #   ]
#   #   resources = ["*"]

#   #   principals {
#   #     type = "AWS"
#   #     identifiers = [
#   #       aws_iam_role.codepipeline_role[0].arn
#   #     ]
#   #   }

#   #   condition {
#   #     test     = "Bool"
#   #     variable = "kms:GrantIsForAWSResource"
#   #     values   = ["true"]
#   #   }
#   # }
# }
