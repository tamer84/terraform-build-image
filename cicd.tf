locals {
  branch = contains(["dev", "test", "int"], terraform.workspace) ? "develop" : "main"
}

module "terraform_build_image_cicd" {
  source = "git::ssh://git@github.com/tamer84/infra.git//modules/cicd?ref=develop"

  codestar_connection_arn = data.terraform_remote_state.account_resources.outputs.git_codestar_conn.arn

  pipeline_base_configs = {
    "name"        = "terraform-build-image-${terraform.workspace}",
    "bucket_name" = data.terraform_remote_state.environment_resources.outputs.cicd_bucket.id,
    "role_arn"    = data.terraform_remote_state.account_resources.outputs.cicd_role.arn,
  }

  codebuild_build_stage = {
    "project_name"        = "terraform-build-image-${terraform.workspace}",
    "github_branch"       = local.branch,
    "github_repo"         = "tamer84/terraform-build-image",
    "github_access_token" = data.terraform_remote_state.account_resources.outputs.github_access_token,
    "github_certificate"  = "${data.terraform_remote_state.environment_resources.outputs.cicd_bucket.arn}/${data.terraform_remote_state.environment_resources.outputs.github_cert.id}",

    "service_role_arn"   = data.terraform_remote_state.account_resources.outputs.cicd_role.arn,
    "cicd_bucket_id"     = data.terraform_remote_state.environment_resources.outputs.cicd_bucket.id,
    "vpc_id"             = data.terraform_remote_state.environment_resources.outputs.vpc.id
    "subnets_ids"        = data.terraform_remote_state.environment_resources.outputs.private-subnet.*.id
    "security_group_ids" = [data.terraform_remote_state.environment_resources.outputs.group_internal_access.id]

    "docker_img_url"                   = "aws/codebuild/standard",
    "docker_img_tag"                   = "4.0",
    "docker_img_pull_credentials_type" = "CODEBUILD",
    "buildspec"                        = "./buildspec.yml",
    "env_vars" = [
      {
        name  = "ENVIRONMENT"
        value = terraform.workspace
      },
      {
        name  = "AWS_DEFAULT_REGION"
        value = "eu-central-1"
      },
      {
        name  = "AWS_ACCOUNT_ID"
        value = "802306197541"
      },
      {
        name  = "IMAGE_TAG"
        value = "latest"
      },
      {
        name  = "IMAGE_REPO_NAME"
        value = aws_ecr_repository.terraform_build_image.name
      },
      {
        name  = "INFRA_DEPLOY_KEY"
        value = tls_private_key.infra_deploy_key.public_key_openssh
      },
      {
        name  = "INFRA_DEPLOY_KEY_PRIV"
        value = format("%q", tls_private_key.infra_deploy_key.private_key_pem)
      }
    ]
  }
}
