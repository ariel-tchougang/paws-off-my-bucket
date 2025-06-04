output "no_access_role_name" {
  description = "IAM role with no S3 permissions"
  value       = aws_iam_role.no_access.name
}

output "access_granted_role_name" {
  description = "IAM role with S3 GetObject allowed"
  value       = aws_iam_role.access_granted.name
}

output "access_granted_duplicate_role_name" {
  description = "Duplicate IAM role with S3 GetObject allowed"
  value       = aws_iam_role.access_granted_duplicate.name
}

output "access_denied_role_name" {
  description = "IAM role with S3 GetObject explicitly denied"
  value       = aws_iam_role.access_denied.name
}
