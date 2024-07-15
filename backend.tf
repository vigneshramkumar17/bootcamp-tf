terraform {
  backend "s3" {
    bucket         = "bootcamp-tf-statefiles-1"
    key            = "terraform.tfstate"
    region         = "us-east-1"  # Replace with your bucket's region
  }
}
