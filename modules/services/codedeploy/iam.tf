
# IAM Role for CodeBuild
# Assume Policy
data "aws_iam_policy_document" "assume_role" {
  count = var.create ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role
resource "aws_iam_role" "codedeploy_role" {
  count              = var.create ? 1 : 0
  name               = "AWSCodeDeployRole-${local.name_prefix}"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags = merge(
    { Name = "AWSCodeDeployRole-${local.name_prefix}" },
    var.custom_tags
  )
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
