terraform {
  backend "s3" {
    bucket       = "airtrail-ecs-fargate-tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}