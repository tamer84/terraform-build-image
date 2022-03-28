resource "aws_ecr_repository" "terraform_build_image" {
  name                 = "terraform-build-image-${terraform.workspace}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Terraform = "true"
  }
}

output "ecr_repository" {
  value = aws_ecr_repository.terraform_build_image
}
