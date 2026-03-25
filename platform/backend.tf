terraform {
  backend "s3" {
    bucket         = "devops-leo-terraform-state"
    key            = "platform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}