# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "${local.bucket_name}"
#   force_destroy = true

#   tags = {
#       Name = "${var.bucket_name}"
#   }
# }

terraform {
    backend "s3" {
        bucket = "terraform-state-banuka-cicd"
        key = "terraform/terraform.tfstate"
        region = "us-east-1"
    }
}

# VPC
resource "aws_vpc" "kubernetes-vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags = {
    Name = "kubernetes-vpc"
  }
}

# Kube-master Subnet
resource "aws_subnet" "kube-master-subnet" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"
  cidr_block = "${var.kube-master_cidr}"

  tags = {
    Name = "kube-master-subnet"
  }
}

# Kube-minion Subnet
resource "aws_subnet" "kube-minion-subnet" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"
  cidr_block = "${var.kube-minion_cidr}"

  tags = {
    Name = "kube-minion-subnet"
  }
}

# Security Group for master
resource "aws_security_group" "sg-kube-master-allow-ssh" {
  name = "kubernetes-master-sg"
  description = "sg to allow only ssh access to kube-master"
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes-master-sg"
  }
}

#Security Group for minions
resource "aws_security_group" "sg-kube-minions-allow-ssh" {
  name = "kubernetes-minion-sg"
  description = "sg to not to allow any inbound traffic, only outbound traffic"
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# IGW
resource "aws_internet_gateway" "kubernetes-igw" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  tags = {
    Name = "kubernetes-igw"
  }
}

# EIP for nat gateway
resource "aws_eip" "kubernetes_eip_for_ngw" {
  vpc = true
}


# NGW - commenting since SLIIT doesn't allow this
# resource "aws_nat_gateway" "kubernetes-ngw" {
#   allocation_id = "${aws_eip.kubernetes_eip_for_ngw.id}"
#   subnet_id = "${aws_subnet.kube-master-subnet.id}"

#   tags = {
#     Name = "kubernetes-ngw"
#   }
# }


# Route Table for kube-master
resource "aws_route_table" "kube-master-rt" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kubernetes-igw.id}"
  }

  tags = {
    Name = "kube-master-rt"
  }
}

# Route Table for kube-minion - commenting since SLIIT doesn't allow to create NGW and this uses it
# resource "aws_route_table" "kube-minion-rt" {
#   vpc_id = "${aws_vpc.kubernetes-vpc.id}"

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = "${aws_nat_gateway.kubernetes-ngw.id}"
#   }

#   tags = {
#     Name = "kube-minion-rt"
#   }
# }


# Associate the kube-master subnet
resource "aws_route_table_association" "kube-master-association" {
  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  route_table_id = "${aws_route_table.kube-master-rt.id}"
}

# Associate the kube-minion subnet
# resource "aws_route_table_association" "kube-minion-association" {
#   subnet_id = "${aws_subnet.kube-minion-subnet.id}"
#   route_table_id = "${aws_route_table.kube-minion-rt.id}"
# }


# Key pair
resource "aws_key_pair" "public" {
  key_name = "gitlab"
  public_key = "${file("${var.public_key_path}")}"
}
 
# Kube-master
resource "aws_instance" "kubernetes-master" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"
  
  key_name = "${aws_key_pair.public.key_name}"

  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-kube-master-allow-ssh.id}"]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum install httpd -y
              yum update -y
              systemctl start httpd
              systemctl enable httpd
              EOF
  tags = {
      Name = "${var.kube-master}"
  }
}

