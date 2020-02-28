terraform {
    backend "s3" {
        bucket = "${local.bucket_name}"
        key = "terraform/terraform.tfstate"
        region = "${local.region}"
    }
}
