variable "ec2-name" {
  type = "string"
}

variable "ec2-type" {
  type = "string"
}

variable "ec2-ami" {
  
}

resource "template_file" "ansible_script" {
  filename = "install_ansible.sh"
}


resource "aws_instance" "kubernetes-instances" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"

  user_data = "${template_file.ansible_script.rendered}"

  tags = {
      Name = "${var.ec2-name}"
  }
  
}