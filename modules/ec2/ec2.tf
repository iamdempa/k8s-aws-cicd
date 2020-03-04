
# Key pair
resource "aws_key_pair" "public" {
  key_name = "gitlab"
  public_key = "${file("${var.public_key_path}")}"
}

# Instances
resource "aws_instance" "kubernetes-master" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"

  count = "${var.count}"
  
  key_name = "${aws_key_pair.public.key_name}"

  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-kube-master-allow-ssh.id}"]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo su -
              yum update -y
              yum install amazon-linux-extras install ansible2 -y
              useradd ansadmin
              passwd ansadmin
              sh -c "echo \"ansadmin ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
              sh -c "echo \"PasswordAuthentication yes\" >> /etc/ssh/ssh_config"
              systemctl restart sshd
            EOF
  tags = {
      Name = "${count.index == 0 ? "kube-master" : "kube-minion-${count.index}"}"
  }
}