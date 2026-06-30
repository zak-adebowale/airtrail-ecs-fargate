resource "aws_ecr_repository" "airtrail" {
  name = "airtrail"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "airtrail-ecr"
  }
}