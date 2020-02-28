module "kubernetes-instances" {
    source = "./module/ec2"
    ami = "ami-07ebfd5b3428b6f4d"
    instance_type = "t2.medium"
    ec2-name = "kube-master"
}