variable "key_name" {
  type        = string
  description = "key pair name"
  default     = "tera-ans.pem"
}

variable "ami_id" {
    type = string
    description = "AMI ID of EC2 Instances"
    default = "ami-08e5424edfe926b43"
}
