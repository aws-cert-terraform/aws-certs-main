###############################################################################
#
# Get variables from command line or environment
#
###############################################################################

variable "modulemap" {
    default = {
         "generic-sg": ["../geneirc-sg", "git@github.com:aws-cert-terraform/generic-iam-role.git"]
    }
}

variable "vpc_cidr" {
    description = "Passed in cidr map"
    default     = "10.2.0.0/16"
}


variable "aws_access_key" {
    description = "The AWS access key."
    default = "AKIAVBFH4B6WQG54TQVB"
}

variable "aws_secret_key" {
    description = "The AWS secret key."
    default = "ntFpH5YQX/UqpfJEt+L+/L0LGfbn8qONUT+CT+Ng"
}

variable "aws_region" {
    description = "The AWS region to create resources in."
    default = "us-east-2"
}

variable "subnets" {
    default = 1
}

variable "local" {
    default = true
}

variable "azs" {
    default = {
        "us-east-2" = "us-east-2a,us-east-2b"
        # use "aws ec2 describe-availability-zones --region us-east-1"
        # to figure out the name of the AZs on every region
    }
}

###############################################################################
#
# Tags
#
###############################################################################

variable "tags" {
    default = {
        "name": "generic",
        "project":"aws-certs",
        "owner" :"icullinane",
        "environment" : "dev"
    }
}
