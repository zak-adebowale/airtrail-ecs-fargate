output "iam_ecs_execution" {
  value = aws_iam_role.ecs_execution.arn
}

output "iam_policy_attach_ecs_execution" {
  value = aws_iam_role_policy_attachment.ecs_execution
}

