terraform {
    backend "s3" {
        bucket = "${var.bucket_name}"
        key = "terraform/terraform.tfstate"
        region = "${var.bucket_region}"
    }
}
