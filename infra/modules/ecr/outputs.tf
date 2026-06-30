output "ecr_repo" {
  value = aws_ecr_repository.airtrail.repository_url
}
