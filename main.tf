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

# vpc
resource "aws_vpc" "kubernetes-vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags = {
    Name = "kubernetes-vpc"
  }
}

# kube-master Subnet
resource "aws_subnet" "kube-master-subnet" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"
  cidr_block = "${var.kube-master_cidr}"

  tags = {
    Name = "kube-master-subnet"
  }
}

# kube-minion Subnet
resource "aws_subnet" "kube-minion-subnet" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"
  cidr_block = "${var.kube-minion_cidr}"

  tags = {
    Name = "kube-minion-subnet"
  }
}

# security Group for master
resource "aws_security_group" "sg-kube-master-allow-ssh" {
  name = "kubernetes-master-sg"
  description = "sg to allow only ssh access to kube-master"
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  # for ansible and kubernetes
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for ansible
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

# security Group for minions
resource "aws_security_group" "sg-kube-minions-allow-ssh" {
  name = "kubernetes-minion-sg"
  description = "sg to not to allow any inbound traffic, only outbound traffic"
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

    # for ansible and kubernetes
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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


# igw
resource "aws_internet_gateway" "kubernetes-igw" {
  vpc_id = "${aws_vpc.kubernetes-vpc.id}"

  tags = {
    Name = "kubernetes-igw"
  }
}

# eip for nat gateway
resource "aws_eip" "kubernetes_eip_for_ngw" {
  vpc = true
}


# ngw - commenting since SLIIT doesn't allow this
# resource "aws_nat_gateway" "kubernetes-ngw" {
#   allocation_id = "${aws_eip.kubernetes_eip_for_ngw.id}"
#   subnet_id = "${aws_subnet.kube-master-subnet.id}"

#   tags = {
#     Name = "kubernetes-ngw"
#   }
# }


# route Table for kube-master
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

# route Table for kube-minion - commenting since SLIIT doesn't allow to create NGW and this uses it
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


# associate the kube-master subnet
resource "aws_route_table_association" "kube-master-association" {
  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  route_table_id = "${aws_route_table.kube-master-rt.id}"
}

# associate the kube-minion subnet
# resource "aws_route_table_association" "kube-minion-association" {
#   subnet_id = "${aws_subnet.kube-minion-subnet.id}"
#   route_table_id = "${aws_route_table.kube-minion-rt.id}"
# }


# key-pair
resource "aws_key_pair" "public" {
  key_name = "gitlab"
  public_key = "${file("${var.public_key_path}")}"
}
 
# kube-master
resource "aws_instance" "kubernetes-master" {
  ami = "${var.ec2-ami}"
  count = 3
  instance_type = "${var.ec2-type}"
  key_name = "${aws_key_pair.public.key_name}"
  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-kube-master-allow-ssh.id}"]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash              
              echo "${file("${var.public_key_path}")}" > /tmp/banuka.txt
              mv /tmp/banuka.txt ~/.ssh/banuka
            EOF

  tags = {
      Name = "${count.index == 0 ? "kube-master" : "kube-minion-${count.index}"}"
  }
}



# kube-minion