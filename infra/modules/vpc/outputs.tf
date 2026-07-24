output "vpc_id" {
  value = aws_vpc.ecs_project_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_sub_group.name
}