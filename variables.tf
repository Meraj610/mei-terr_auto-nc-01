variable "access_key" {
  type        = string
  description = "AWS access key. Can also be set with the AWS_ACCESS_KEY_ID environment variable, or via a shared credentials file if profile is specified."
}

variable "secret_key" {
  type        = string
  description = "Can also be set with the AWS_SECRET_ACCESS_KEY environment variable, or via a shared configuration and credentials files if profile is used."
}

variable "region" {
  default     = "us-west-1"
  type        = string
  description = "AWS region where the provider will operate. The region must be set. Can also be set with either the AWS_REGION or AWS_DEFAULT_REGION environment variables, or via a shared config file parameter region if profile is used. "
}

variable "cidr_block" {
  default     = "10.1.0.0/16"
  type        = string
  description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using ipv4_netmask_length"
}

variable "instance_tenancy" {
  default     = "default"
  type        = string
  description = "A tenancy option for instances launched into the VPC. Default is default, which ensures that EC2 instances launched in this VPC use the EC2 instance tenancy attribute specified when the EC2 instance is launched. The only other option is dedicated, which ensures that EC2 instances launched in this VPC are run on dedicated tenancy instances regardless of the tenancy attribute specified at launch."
}

variable "enable_dns_support" {
  default     = true
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults to true."
}


variable "enable_dns_hostnames" {
  default     = true
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}


variable "environment" {
  type        = string
  description = "name/description of the environment"
}
