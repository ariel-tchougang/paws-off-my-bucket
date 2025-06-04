locals {
  s3_resources = [
    "arn:aws:s3:::${var.bucket_name}",
    "arn:aws:s3:::${var.bucket_name}/*"
  ]
}

resource "aws_iam_role" "no_access" {
  name = "DemoNoS3PermissionsRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "access_granted" {
  name = "DemoS3AccessGrantedRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "access_granted_duplicate" {
  name = "DemoDuplicateS3AccessGrantedRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "access_denied" {
  name = "DemoS3AccessDeniedRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "allow_getobject_granted" {
  name   = "AllowGetObject"
  role   = aws_iam_role.access_granted.name
  policy = data.aws_iam_policy_document.allow_getobject.json
}

resource "aws_iam_role_policy" "allow_getobject_duplicate" {
  name   = "AllowGetObjectDuplicate"
  role   = aws_iam_role.access_granted_duplicate.name
  policy = data.aws_iam_policy_document.allow_getobject.json
}

resource "aws_iam_role_policy" "deny_getobject" {
  name   = "DenyGetObject"
  role   = aws_iam_role.access_denied.name
  policy = data.aws_iam_policy_document.deny_getobject.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "allow_getobject" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = local.s3_resources
  }
}

data "aws_iam_policy_document" "deny_getobject" {
  statement {
    effect = "Deny"
    actions = ["s3:GetObject"]
    resources = local.s3_resources
  }
}

data "aws_caller_identity" "current" {}
