terraform {
  backend "s3" {
    bucket         = "miguel-terraform-state-proyecto2"
    key            = "proyecto3/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "personal"
    dynamodb_table = "terraform-locks-proyecto2"
    encrypt        = true
  }
}
