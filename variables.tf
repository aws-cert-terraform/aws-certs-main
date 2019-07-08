###############################################################################
#
# Get variables from command line or environment
#
###############################################################################


variable "aws_access_key" {
    description = "The AWS access key."
    default = "..."
}

variable "aws_secret_key" {
    description = "The AWS secret key."
    default = "..."
}

variable "aws_region" {
    description = "The AWS region to create resources in."
    default = "us-east-2"
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
variable "name" {
    default = "generic-vpc"
}

variable "project" {
    default = "aws-cert"
}

variable "owner" {
    default = "icullinane"
}

variable "environment" {
    default = "dev"
}
