variable "default_tags" {
  type = map(string)
  default = {
    "env" = "dbaeten-terraform"
  }
  description = "Describing my resource"
}

variable "public_subnet_count" {
  type = number
  description = "Public Subnet Count"
  default = 2
}

variable "private_subnet_count" {
  type = number
  description = "Private Subnet Count"
  default = 2
}

variable "vpc_cidr" {
  type = string
  default = "11.0.0.0/16"
  description = "Main VPC Cidr block"
}
