variable "public_key_path" {
  type = "string"
  default = "/home/gitlab-runner/.ssh/gitlab.pub"
}

variable "ec2-ami" {
  type = "string"
  default = "ami-07ebfd5b3428b6f4d"
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
