variable "ec2-name" {
  type = "string"
}

variable "ec2-type" {
  type = "string"
}

variable "ec2-ami" {
  
}

variable "public_key_path" {
  type = "string"
  default = "/root/.ssh/gitlab.pub"
}


# create an aws keypair

resource "aws_key_pair" "public" {
  key_name = "master_key"
  public_key = "${file("${var.public_key_path}")}"
}


resource "aws_instance" "kubernetes-instances" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"

  # user_data = "${file(install_ansible.sh)}"

	# user_data = <<EOF
	# 	#!/bin/bash
  #   sudo su -
  #   sudo apt-get update
	# 	sudo apt-get install apache2 -y
	# 	sudo systemctl start apache2
	# 	sudo systemctl enable apache2
	# EOF

  tags = {
      Name = "${var.ec2-name}"
  }
  
}