resource "aws_instance" "kubernetes-instances" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"

  tags = {
      Name = "${var.ec2-name}"
  }
}