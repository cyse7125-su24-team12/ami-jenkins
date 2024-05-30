packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "admin_username" {
  type    = string
  default = env("ADMIN_USERNAME")
}

variable "admin_password" {
  type    = string
  default = env("ADMIN_PASSWORD")
}

variable "aws_region" {
  type    = string
  default = env("AWS_REGION")
}

source "amazon-ebs" "ami-jenkins" {
  ami_name              = "csye7125-{{timestamp}}"
  force_delete_snapshot = true
  // access_key            = var.access_key
  // secret_key            = var.secret_key
  region        = var.aws_region
  instance_type = "t2.small"
  ssh_username  = "ubuntu"
  // associate_public_ip_address = true
  // ssh_interface               = "public_ip"
  // ami_virtualization_type = "hvm"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  sources = ["source.amazon-ebs.ami-jenkins"]

  provisioner "shell" {
    environment_vars = [
      "ADMIN_USERNAME=${var.admin_username}",
      "ADMIN_PASSWORD=${var.admin_password}"
    ]
    scripts = [
      "./scripts/jenkinsinstall.sh",
      "./scripts/setupjenkins.sh",
      "./scripts/caddysetup.sh"
    ]
  }
}
