
# provide the s3 bucket for storing state file
terraform {
  backend "s3" {
    bucket         = "web-application-terraform-bucket"
    key            = "path/to/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "my-terraform-lock"
    acl            = "private"
  }
}