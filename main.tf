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

resource "aws_key_pair" "public" {
  key_name = "gitlab"
  public_key = "${file("${var.public_key_path}")}"
}

# module "kubernetes-instances" {

#     source = "./modules/ec2"
#     ec2-ami = "ami-07ebfd5b3428b6f4d"
#     ec2-type = "t2.medium"
#     ec2-name = "kube-master"
# } 

resource "aws_instance" "kubernetes-master" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"
  key_name = "${aws_key_pair.public.id}"
  subnet_id = "${aws_subnet.kube-master-subnet.id}"

  tags = {
      Name = "${var.kube-master}"
  }
  
}

# Security Group for master
resource "aws_security_group" "kube-master-allow-ssh" {
  name = "kubernetes-master sg"
  description = "sg to allow only ssh access to kube-master"
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
