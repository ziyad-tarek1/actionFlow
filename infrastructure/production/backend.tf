terraform {
  backend "s3" {
    bucket         = "hjvkjbkjlbjl"
    key            = "infrastructure/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
