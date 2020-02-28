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

  # user_data = "${file(install_ansible.sh)}"

	user_data = << EOF
		#! /bin/bash
    sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF

  tags = {
      Name = "${var.ec2-name}"
  }
  
}