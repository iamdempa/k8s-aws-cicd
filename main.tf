

module "kubernetes-instances" {

    source = "./module/ec2"
    ec2-ami = "ami-07ebfd5b3428b6f4d"
    ec2-type = "t2.medium"
    ec2-name = "kube-master"
    
}