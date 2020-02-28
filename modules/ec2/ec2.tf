variable "ec2-name" {
  type = "string"
}

variable "ec2-type" {
  type = "string"
}

variable "ec2-ami" {
  
}


resource "aws_instance" "kubernetes-instances" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"

  user_data = "${file("./install_ansible.sh")}"

  tags = {
      Name = "${var.ec2-name}"
  }
  
}