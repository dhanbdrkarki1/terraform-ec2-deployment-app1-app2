data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}


data "aws_codestarconnections_connection" "this" {
  count = var.create ? 1 : 0
  name  = var.codestarconnection_name
}
