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


variable "public_key_path" {
  type = "string"
  default = "/home/gitlab-runner/.ssh/gitlab.pub"
}

# create an aws keypair
resource "aws_key_pair" "public" {
  key_name = "master_key"
  public_key = "${file("${var.public_key_path}")}"
}


module "kubernetes-instances" {

    source = "./modules/ec2"
    ec2-ami = "ami-07ebfd5b3428b6f4d"
    ec2-type = "t2.medium"
    ec2-name = "kube-master"
    key_name = "${aws_key_pair.public}"
} 