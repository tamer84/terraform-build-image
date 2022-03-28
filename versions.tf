terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.31"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }
  required_version = "= 1.0.5"
}
