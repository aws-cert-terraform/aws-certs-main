
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


/*
Base VPC to build into, distinct from a default VPC(!)
*/
module "aws_cert_vpc" {
  source = "git@github.com:aws-cert-terraform/generic-vpc.git"
  name = "${var.tags.name}"
  vpc_cidr = "${var.vpc_cidr}"
  tags = var.tags
}

/*
General Access IAM Role allows actions between S3 and EC2
*/
module "general_access_iam_role" {
  source = "git@github.com:aws-cert-terraform/generic-iam-role.git"
  // vpc_id = "${module.aws_cert_vpc.vpc_id}"
  prefix = "${var.tags.owner}-"
}

/*
Security Group to contain rules regarding web servers
*/
module "web_dmz" {
  source = "git@github.com:aws-cert-terraform/generic-sg.git"
  name = "  ${var.tags.name}-${var.tags.owner}-web_dmz"
  vpc_id = "${module.aws_cert_vpc.vpc_id}"
}

# Security groups
resource "aws_security_group" "mysql_sg" {
  name = "$${var.tags.name}-${var.tags.owner}-mysql_sg"
  vpc_id = "${module.aws_cert_vpc.vpc_id}"
}

/*
Generic SG allows all outbound and opens ssh port.
TODO::Pass in rules
*/
module "aws_cert_generic_sg" {
  source = "git@github.com:aws-cert-terraform/generic-sg.git"
  name = "generic_access_sg_${var.tags.name}-${var.tags.owner}"
  vpc_id = "${module.aws_cert_vpc.vpc_id}"
}


//
// Note to self, these rules ATTACH to the sg above
//

# Security groups
resource "aws_security_group_rule" "allow_mysql_port" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = "${module.web_dmz.security_group_id}"
  security_group_id = "${aws_security_group.mysql_sg.id}"
}



/*
Generic DB is a postgres RDS gp2 instance
*/
module "aws_cert_generic_db" {
  source = "git@github.com:aws-cert-terraform/generic-db.git"
  name = "awscertdb"
  security_group_ids = ["${module.web_dmz.security_group_id}", "${aws_security_group.mysql_sg.id}"]
  subnet_ids = values(module.aws_cert_vpc.public_subnets)
}


/*
Application load balancer
- Handles its own S3 log bucket
*/
module "aws_cert_generic_lb" {
  source = "git@github.com:aws-cert-terraform/generic-lb.git"
  name = "generic-lb"
  vpc_id = "${module.aws_cert_vpc.vpc_id}"
  security_groups = ["${module.aws_cert_generic_sg.security_group_id}"]
  subnet_ids = values(module.aws_cert_vpc.public_subnets)
}



/*
Basic container running Amazon Linux
*/
module "ec2_web_server" {
  source = "git@github.com:aws-cert-terraform/generic-ec2.git"
  name = "aws-certs-ec2"
  key_name = "cert-key-e2"
  iam_profile_name = "${module.general_access_iam_role.iam_profile_name}"
  vpc_id = "${module.aws_cert_vpc.vpc_id}"
  vpc_security_group_ids = [
    "${module.aws_cert_generic_sg.security_group_id}", 
    "${module.web_dmz.security_group_id}"
  ]
  vpc_subnet_id = lookup(module.aws_cert_vpc.public_subnets, "2a")
  prefix = "${var.tags.owner}"
  public = true
}

/*
Actual bit that attaches the lb to an instance
TODO::Use ASG instead
*/
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = "${module.aws_cert_generic_lb.target_group_arn}"
  target_id        = "${module.ec2_web_server.instance_id}"
  port             = 80
}
