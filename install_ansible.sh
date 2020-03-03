sudo su -
yum update -y
yum install amazon-linux-extras install ansible2 -y
useradd ansadmin
passwd ansadmin
sh -c "echo \"ansadmin ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
sh -c "echo \"PasswordAuthentication yes\" >> /etc/ssh/ssh_config"
systemctl restart sshd