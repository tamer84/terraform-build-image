resource "tls_private_key" "infra_deploy_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "github_repository_deploy_key" "infra_github_deploy_key" {
  title      = "Terraform deploy key ${terraform.workspace}"
  repository = "infra"
  key        = tls_private_key.infra_deploy_key.public_key_openssh
  read_only  = "true"
}
