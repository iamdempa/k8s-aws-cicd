variable "public_key_path" {
  type = "string"
  default = "/home/gitlab-runner/.ssh/gitlab.pub"
}

variable "ec2-ami" {
  type = "string"

  # ubuntu
  # default = "ami-07ebfd5b3428b6f4d"

  #centos
  default = "ami-0a887e401f7654935"

}

variable "instance_count" {
  type = "number"
  default = 3
}


variable "ec2-type" {
  type = "string"
  default = "t2.medium"
}

variable "kube-master" {
  type = "string"
  default = "kube-master"
}

variable "kube-minion" {
  type = "string"
  default = "kube-minion"
}

variable "vpc_cidr_block" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "kube-master_cidr" {
  type = "string"
  default = "10.0.0.0/21"
}

variable "kube-minion_cidr" {
  type = "string"
  default = "10.0.8.0/21"
}