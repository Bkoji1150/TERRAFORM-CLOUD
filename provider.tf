provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.required_tags.aws_default_tags
  }
}
