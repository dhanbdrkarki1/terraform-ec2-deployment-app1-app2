# for creating a new S3 bucket for storing pipeline artifacts
resource "random_string" "this" {
  count   = var.create ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  count         = var.create ? 1 : 0
  bucket        = "${local.name_prefix}-codepipeline-artifact-${random_string.this[0].id}"
  force_destroy = true

  tags = merge(
    { Name = "${local.name_prefix}-codepipeline-artifact-${random_string.this[0].id}" },
    var.custom_tags
  )
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket_owner" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.codepipeline_bucket[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.codepipeline_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
#   count  = var.create ? 1 : 0
#   bucket = aws_s3_bucket.codepipeline_bucket[0].id
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "${aws_iam_role.codepipeline_role[0].arn}"
#         },
#         "Action" : [
#           "s3:Get*",
#           "s3:List*",
#           "s3:ReplicateObject",
#           "s3:PutObject",
#           "s3:RestoreObject",
#           "s3:PutObjectVersionTagging",
#           "s3:PutObjectTagging",
#           "s3:PutObjectAcl"
#         ],
#         "Resource" : [
#           "${aws_s3_bucket.codepipeline_bucket[0].arn}",
#           "${aws_s3_bucket.codepipeline_bucket[0].arn}/*",
#         ]
#       }
#     ]
#   })
# }

# S3 Policies
resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.codepipeline_bucket[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "codepipeline.amazonaws.com"
          ]
        },
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "${aws_s3_bucket.codepipeline_bucket[0].arn}",
          "${aws_s3_bucket.codepipeline_bucket[0].arn}/*"
        ],
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : [
              "${aws_codepipeline.this[0].arn}",
              "${var.codebuild_arn}"
            ]
          }
        }
      }
    ]
  })
}

# S3 Bucket ACLs
resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  count = var.create ? 1 : 0
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_bucket_owner,
    aws_s3_bucket_public_access_block.codepipeline_bucket_pab,
  ]
  bucket = aws_s3_bucket.codepipeline_bucket[0].id
  acl    = "private"
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.codepipeline_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server side encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket_encryption" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.codepipeline_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# S3 Bucket Logging
resource "aws_s3_bucket_logging" "codepipeline_bucket_logging" {
  count         = var.create ? 1 : 0
  bucket        = aws_s3_bucket.codepipeline_bucket[0].id
  target_bucket = aws_s3_bucket.codepipeline_bucket[0].id
  target_prefix = "log/"
}
