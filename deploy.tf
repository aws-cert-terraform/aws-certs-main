
###############################################################################
#
# Specify provider
#
###############################################################################

provider "ignition" {}

# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.name}-${var.environment}"
        Project = "${var.project}"
        Owner = "${var.owner}"
        Environment = "${var.environment}"
    }
}
